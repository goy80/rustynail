# coding: utf-8

module Rustynail
  module ActionViewExtension

    def facet_options facets={}
      facet_options = Rustynail::Helpers::FacetOption.new( facets )
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

  end
end
