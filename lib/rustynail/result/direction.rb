# coding: utf-8

module Rustynail::Result
  class Direction

    attr :sort_by, :sort_direction, :sortable_columns

    def initialize str = nil, opt = {}
      @sort_by = nil
      @sort_direction = nil
      unless str.nil?
        array = str.strip.split(" ")
        @sort_by = array[ 0 ].to_sym unless array[ 0 ].nil?
        @sort_direction = array[ 1 ].to_sym unless array[ 1 ].nil?
      end
      @sortable_columns = opt[ :sortable_columns ].presence || []
    end

    #
    # 日本語にして返す。
    # @TODO 汎用化
    #
    def to_s
      ret = ""
      if @sort_by == :updated_at
        if @sort_direction == :asc
          ret = "古い順"
        else
          ret = "更新順"
        end
      elsif @sort_by == :sales_rank
        ret = "人気順"
      elsif @sort_by == :price
        if @sort_direction == :asc
          ret = "安い順"
        else
          ret = "高い順"
        end
      else
      end
      ret
    end

  end
end
