# coding: utf-8

require "rustynail/version"
require "rustynail/result/base"

module Rustynail

  extend ActiveSupport::Concern

  @@full_text_search_columns = []
  @@facet_columns = []
  @@sortable_columns = []
  @@default_sort = []
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

    # デフォルトのソート順
    def self.default_sort sort
      @@default_sort = sort
    end

    #
    # 検索結果、ファセットオプションなどをまとめて返す。
    #
    # @return [Result::Base]
    #
    def self.facet_search( filter = {} )
      begin
        list = search( filter )
        @result = Result::Base.new( self, list: list, direction: sort_direction, filter: filter )
      rescue => ex
        Rails.logger.error "exception occur during facet_search. message=#{ ex.message }, backtrace is bellow.\n #{ ex.backtrace.join( "\n" )}"
        raise "fail_to_facet_search"
      end
    end

    #
    # 初期状態（検索実行前）に検索結果オブジェクトを返す。
    #
    # @return [Result::Base]
    #
    def self.facet_search_initial_result
      Result::Base.new( self )
    end


    def self.sort_direction
      direction = Result::Direction.new( @direction, sortable_columns: @@sortable_columns )
    end


    #
    # 検索結果の取得
    #
    scope :search, ->( filter={} ){

      raise "full_text_search_columns not specified." if @@full_text_search_columns.blank?

      cond = []
      values = {}
      filter = {} if filter.nil?

      # 全文検索による絞込み
      if filter[ :keyword ].present?
        columns = @@full_text_search_columns.map{ | column | "`#{column}`" }
        cond << %! MATCH( #{ columns.join(" ,") } ) AGAINST( :keyword IN BOOLEAN MODE) !
        values[ :keyword ] = filter[ :keyword ]
      end

      # ファセットオプションよる絞込み
      @@facet_columns.each do | column |
        if filter.key? column
          cond << " #{column} = :#{column} "
          values[ column ] = filter[ column ]
        end
      end

      # OrderBy
      if filter.key?( "order_by" )
        orders = merge_order( filter[ "order_by" ], filter[ "direction"] )
      else
        orders = @@default_sort
      end

      # ソート順
      @direction = orders.first

      # 検索の実行
      ret = self.where( cond.join(" AND "), values  )
          .order( orders.join(", ") )
          .limit( @@search_limit )

      ret
    }

    #
    # 選択されたソート順とデフォルトのソート順のマージ
    #
    # @param [ String ] order_by ソートカラム名
    # @param [ String ] direction asc or desc
    #
    def self.merge_order( order_by, direction )
      reserve = {}
      @@default_sort.each do | sort |
        ary = sort.split( " " )
        reserve[ ary[ 0 ].to_s.strip ] = ary[ 1 ].to_s.strip
      end
      reserve.delete order_by

      orders = []
      orders << "#{ order_by } #{ direction }"
      reserve.each do | column, direction |
        orders << "#{ column } #{ direction }"
      end
      orders
    end

    #
    # 検索結果の絞りこみに使えるファセット検索選択肢を返す。
    #
    # @param [ Hash ] flter 検索条件
    # @return [ Result::Options ] ファセット検索条件オブジェクト
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


