# coding: utf-8

module Rustynail
  module ActionViewExtension

    #
    # ファセット検索のviewを返す。
    #
    # @params [ Hash ] opt ファセット検索結果。
    # @option opt [ Hash ] :facet_option ファセット検索の選択肢。
    # @option opt [ Result::Direction ] :sort_direction 検索結果ソート順。
    # @option opt [ Hash ] :filter 現在選択されている検索条件。
    # @option opt [ Hash ] :locals ビューにローカル変数として渡す値。
    #
    def facet_options opt={}
      facets = opt[ :facet_option ].presence || {}
      sort_direction = opt[ :sort_direction ]
      filter = opt[ :filter ] || {}
      locals = opt[ :locals ] || {}

      facet_options = Rustynail::Helpers::FacetOption.new( facets, sort_direction, filter )
      facet_options.to_html( locals: locals )
    end

    #
    # ファセット検索オプションの日本語表記を返す。
    #
    def opt_name_label column, opt_name

      ret = nil
      column = column.to_sym
      opt_name = opt_name.to_s
      converter = Rustynail.config.option_name_converter

      if !converter.nil?
        if converter.key?( column ) && converter[ column ].key?( opt_name )
          ret = converter[ column ][ opt_name ]
        end
      end
      ret = opt_name if ret.nil?
      ret

    end

    #
    # カラム名の日本語表記を返す。
    #
    def column_name_label column
      column = column.to_sym
      converter = Rustynail.config.column_name_converter
      ret = nil
      if !converter.nil?
        if converter.key?( column )
          ret = converter[ column ]
        end
      end
      ret = column if ret.nil?
      ret
    end

    #
    # ソートオプションの日本語表記を返す。
    #
    def sort_option_label( column, direction )
      ret = nil
      begin
        ret = Rustynail.config.sort_option_converter[ column ][ direction ]
      end
      ret = "#{column} #{direction}" if ret.nil?
      ret
    end


    #
    # 選択肢の上限に達していればtrue
    #
    def facet_max? count
      Rustynail.config.facet_max > 0 && count >= Rustynail.config.facet_max
    end

    #
    # ファセット検索結果へのパスを返す。
    #
    # @param [ String ] column 変更カラム名
    # @param [ String/Numeric ] value 変更値
    # @param [ Hash ] filter 現在選択されている検索条件
    # @return [ String ] ファセット検索結果へのパス
    #
    def facet_search_path( column, value, filter = {} )
      Rustynail.config.search_action_name.to_s+"?"+build_query_string( column, filter, :select, value )
    end

    #
    # columnの条件をはずした検索結果へのパスを返す。
    #
    def back_search_path( column, filter = {} )
      Rustynail.config.search_action_name.to_s+"?"+build_query_string( column, filter, :remove )
    end

    #
    # ソート順を変えた検索結果へのパスを返す。
    #
    def sort_result_path( column, direction, filter = {} )
      filter = build_filter( :order_by, filter, :select, column ).symbolize_keys
      Rustynail.config.search_action_name.to_s+"?"+build_query_string( :direction, filter, :select, direction )
    end


    #
    # ファセット検索結果へのクエリーストリングの作成
    #
    # @return [ String ] 検索結果パスのクエリーストリング
    #
    def build_query_string( column, orig_filter = {}, operation = :select, value = nil )
      params = build_filter( column, orig_filter, operation, value )
      params.to_query( Rustynail.config.qs_filter_name )
    end

    def build_filter( column, orig_filter = {}, operation = :select, value = nil )
      filter = orig_filter.dup
      if operation == :select
        ary0 = filter.merge( { column.to_sym => value } )
        ary = ary0.sort
        params = Hash[ *ary.flatten ]
      else
        filter.delete( column.to_sym )
        params = filter
      end
      params
    end


    #
    # 選択中のオプションかどうか
    #
    def selected_option?( column, opt_name, filter = {} )
      filter[ column ].to_s == opt_name.to_s
    end

    #
    # 選択中のソートオプションかどうか
    #
    def selected_sort?( column, direction, filter )
      filter[ :order_by ].to_s == column.to_s && filter[ :direction ].to_s == direction.to_s
    end

  end
end
