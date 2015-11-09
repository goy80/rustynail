# coding: utf-8

module Rustynail
  module ActionViewExtension

    def facet_options facets={}
      facet_options = Rustynail::Helpers::FacetOption.new( facets )
      facet_options.to_s
    end

  end
end
