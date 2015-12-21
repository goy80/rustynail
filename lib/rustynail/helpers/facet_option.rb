# coding: utf-8


module Rustynail
  module Helpers
    class FacetOption

      #
      # @param [ Result::Base ] 検索結果オブジェクト
      #
      def initialize( result, facet={}, sort_direction = nil, filter = {} )
        @result = result
        @facet = facet
        @direction = sort_direction
        @filter = filter
      end

      #
      # ファセットオプションのHTMLを返す。
      #
      # @param [Hash] opt
      # @option opt [Hash] :locals viewに渡す変数
      #
      def to_html( opt={} )
        locals = {
          result: @result,
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
