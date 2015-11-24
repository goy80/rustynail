# coding: utf-8


module Rustynail
  module Helpers
    class FacetOption

      def initialize facet={}, sort_direction = nil, filter = {}
        @facet = facet
        @direction = sort_direction
        @filter = filter
      end

      def to_s( opt={} )
        locals = {
          options: @facet,
          sort_direction: @direction,
          filter: @filter
        }.merge( opt[ :locals ].presence || {} )

        action_view = ActionView::Base.new
        action_view.view_paths << File.join( Rails.root, "/app/views/rustynail" )
        action_view.view_paths << File.expand_path( '../../../../app/views/rustynail', __FILE__ )
        action_view.render( partial: "facet_option", locals: locals )
      end


    end
  end
end
