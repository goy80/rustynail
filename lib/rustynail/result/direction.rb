# coding: utf-8

module Rustynail::Result
  class Direction

    #
    # :sortable_columns = {
    #   :対象カラム => [ ( :asc, :desc ) ]
    # }
    #
    #
    attr :sort_by, :sort_direction, :sortable_columns

    #
    # 初期化
    #
    # @param [String] str @sort_by, @sort_directionを半角スペースで区切った文字列 (ex. "price desc")
    # @param [Hash] opt
    # @option opt [Hash] :sortable_columns ({}) 可能なソートオプション。 { :対象カラム名 => [ ( :asc, :desc ) ] }
    #
    def initialize( str = nil, opt = {} )
      @sort_by = nil
      @sort_direction = nil
      unless str.nil?
        array = str.strip.split(" ")
        @sort_by = array[ 0 ].to_sym unless array[ 0 ].nil?
        @sort_direction = array[ 1 ].to_sym unless array[ 1 ].nil?
      end

      # sortable_columns = { column => [ one of or both of :asc, :desc ] }
      if opt.key?( :sortable_columns )
        opt[ :sortable_columns ].each_with_index do | column, idx |
          unless column.is_a?( Hash )
            opt[ :sortable_columns ][ idx ] = { column => [ :asc, :desc ] }
          end
        end
      else
        opt[ :sortable_columns ] = []
      end
      @sortable_columns = opt[ :sortable_columns ]
    end

    #
    # ソート方法の日本語を返す。（ex.　安い順）
    #
    def to_s
      Rustynail.config.sort_option_converter[ @sort_by ][ @sort_direction ] || "不明なソート方法"
    end

    #
    # @param [Symbol] column ソートのカラム名
    # @param [Symbol] direction ソートの方向(:asc, :desc)
    #
    def selected_sort?( column, direction )
      column.to_sym == @sort_by && direction.to_sym == @sort_direction
    end

  end
end
