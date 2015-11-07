# coding: utf-8

require "rustynail/version"
require "rustynail/result/base"

module Rustynail

  extend ActiveSupport::Concern

  @@full_text_search_columns = []
  @@facet_columns = []
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

    # 検索の実行
    scope :search, ->( keyword, filter={} ) do

      cond = []
      values = {}
      filter = {} if filter.nil?
      orders = [ "sales_rank", "price desc" ]

      # 絞込み条件
      if keyword.present?
        cond << %! MATCH( `asin`,`title`,`maker`,`feature`,`description`,`item_attributes` ) AGAINST( :keyword IN BOOLEAN MODE) !
        values[ :keyword ] = keyword
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

      # 検索の実行
      ret = self.where( cond.join(" AND "), values  )
          .order( orders.join(", ") )
          .limit( @@search_limit )


      @result = Result::Base.new(  data: ret, direction: orders.first )
      ret

    end



    #
    # ファセットを返す
    #
    def self.facet_options opt = {}, filter = {}
      begin
        filter ||= {}

        if @@full_text_search_columns.blank?
          raise "full-text-search-columns not specified."
        end

        opt = {} if opt.nil?
        opt.each do | key, value |
          filter[ key.to_sym ] = value
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

        ret
      rescue => ex
        Rails.logger.error "exception: message = #{ ex.message }. backtrace is bellow.\n #{ ex.backtrace.join("\n") }"
      end

    end

    #
    # 選択中のソート順を返す
    #
    def self.selected_direction
      @result.direction.to_s
    end


  end
end
