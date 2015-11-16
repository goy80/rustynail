# coding: utf-8


module Rustynail
  module Helpers
    class FacetOption

      def initialize facet={}, direction = nil, filter = {}
        @facet = facet
        @direction = direction
        @filter = filter
      end

      def to_s
        action_view = ActionView::Base.new
        action_view.view_paths = File.expand_path( '../../../../app/views', __FILE__ )
        action_view.render( partial: "facet_option", locals: { options: @facet, direction: @direction, filter: @filter } )
      end


    end
  end
end
