# coding: utf-8

module Rustynail
  module ActionViewExtension

    def facet_options facets = {}, sort_direction = nil
      facet_options = Rustynail::Helpers::FacetOption.new( facets, sort_direction )
      facet_options.to_s
    end

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
    # 選択肢の上限に達していればtrue
    #
    def facet_max? count
      Rustynail.config.facet_max > 0 && count >= Rustynail.config.facet_max
    end

  end
end
