# coding: utf-8

require "rustynail/version"
require "rustynail/result/base"

module Rustynail

  extend ActiveSupport::Concern

  @@full_text_search_columns = []
  @@facet_columns = []
  @@sortable_columns = []
  @@table_name = "my_table"
  @@search_limit = 200


  included do

    @@table_name =  self.table_name

    # 全文検索の対象フィールド
    def self.full_text_search_columns columns
      @@full_text_search_columns = columns
    end

    # ファセット検索の対象フィールド
    def self.facet_columns columns
      @@facet_columns = columns
    end

    # ソート可能フィールド
    def self.sortable_columns columns
      @@sortable_columns = columns
    end

    #
    # 検索結果、ファセットオプションなどをまとめて返す。
    #
    # @return Result::Base
    #
    def self.facet_search( filter = {} )
      begin
        list = search( filter )
        options = facet_options( filter )
        @result = Result::Base.new( list: list, options: options, direction: sort_direction )
      rescue => ex
        Rails.logger.error "exception occur during facet_search. message=#{ ex.message }, backtrace is bellow.\n #{ ex.backtrace.join( "\n" )}"
        raise "fail_to_facet_search"
      end
    end


    def self.sort_direction
      direction = Result::Direction.new( @direction, sortable_columns: @@sortable_columns )
    end


    #
    # 検索の実行
    #
    scope :search, ->( filter={} ) do

      cond = []
      values = {}
      filter = {} if filter.nil?
      orders = [ "sales_rank", "price desc" ]

      # 絞込み条件
      if filter[ :keyword ].present?
        cond << %! MATCH( `asin`,`title`,`maker`,`feature`,`description`,`item_attributes` ) AGAINST( :keyword IN BOOLEAN MODE) !
        values[ :keyword ] = filter[ :keyword ]
      end
      if filter.key? "price_zone"
        cond << " price_zone = :price_zone "
        values[ :price_zone ] = filter[ "price_zone" ]
      end
      if filter.key? "maker"
        cond << " maker = :maker "
        values[ :maker ] = filter[ "maker" ]
      end

      # OrderBy
      if filter.key?( "orderby" ) && ["updated_at","price","sales_rank"].include?( filter[ "orderby" ] )

        direc = "asc"
        if filter.key?( "direction" ) && [ "asc", "desc" ].include?( filter[ "direction"] )
          direc = filter[ "direction" ]
        end
        orders =  [ filter[ "orderby" ] + " " + direc ]

        unless filter[ "orderby" ] == "price"
          orders << "price desc"
        end
        unless filter[ "orderby" ] == "sales_rank"
          orders << "sales_rank"
        end

      end

      # ソート順
      @direction = orders.first

      # 検索の実行
      ret = self.where( cond.join(" AND "), values  )
          .order( orders.join(", ") )
          .limit( @@search_limit )

      Rails.logger.debug "facet_search: list sql=#{ ret.to_sql}"
      ret
    end



    #
    # ファセットを返す
    #
    def self.facet_options( filter = {} )
      begin
        filter ||= {}

        if @@full_text_search_columns.blank?
          raise "full-text-search-columns not specified."
        end

        # filterオプションの構築
        filter_conds = []
        @@facet_columns.each do | column |
          if filter.key? column
            value = filter[ column ]
            unless self.columns.find{ |col| col.name == column.to_s }.number?
              value = %!\""#{ value }\""!
            end

            filter_conds << "#{ column } == #{ value }"
          end
        end
        filter_option = filter_conds.length > 0 ? %!--filter '#{ filter_conds.join(" && ") }'! : ""

        #
        # --match_columns 全文検索対象カラム
        # --filter 絞込み条件
        #
        sql = %!SELECT mroonga_command("select #{ @@table_name } \
                --limit 0 \
                --match_columns '#{ @@full_text_search_columns.join("||") }' \
                --query '#{ filter[ :keyword ] }' #{filter_option} \
                --drilldown '#{ @@facet_columns.join(",") }' \
                --drilldown_sortby '-_nsubrecs, _key' \
                --drilldown_limit -1 \
                ") AS facet_options !

        dum = connection.select sql
        res = JSON.parse( dum.first["facet_options"] )
        res.delete_at( 0 )

        ret = {}
        @@facet_columns.each_with_index do | column, idx |
          2.times do
            res[ idx ].delete_at 0
          end
          ret[ column.to_s ] = Hash[ *res[ idx ].flatten ]
        end

        Rails.logger.debug "facet_options: #{ ret.inspect }"

        Result::Options.new( ret )
      rescue => ex
        Rails.logger.error "exception: message = #{ ex.message }. backtrace is bellow.\n #{ ex.backtrace.join("\n") }"
      end

    end


  end
end

require "rustynail/config"
require "rustynail/action_view_extension"
require "rustynail/hooks"
require "rustynail/railtie"
require "rustynail/helpers/facet_option"


