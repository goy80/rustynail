# coding: utf-8

require "rustynail/result/direction"
require "rustynail/result/options"

#
# ファセット検索結果オブジェクト。
#
# メンバー
#
module Rustynail::Result
  class Base

    attr :list, :facet_options, :direction, :filter

    #
    # @param [ Class ] include_class RustynailをMix-inしたクラス。
    # @param [ Hash ] opts
    # @option opts [ Hash ] :filter 選択された検索条件。
    # @option opts [ ActiveRecord::Relation ] :list 検索結果。
    # @option opts [ Result::Direction ] :direction 検索結果のソート順オブジェクト。
    #
    def initialize( include_class, opts={} )
      @include_class = include_class
      @filter = opts[ :filter ] || {}
      @list = opts[ :list ]
      @direction = opts[ :direction ].presence || Direction.new( "" )
    end

    #
    # 選択中のファセットオプションかどうか。
    #
    # @param [Symbol] colum 対象カラム
    # @param [String] option オプション名
    #
    #
    def selected_option?( column, option )
      @filter[ column.to_s ] == option.to_s
    end

    #
    # 検索結果の絞込みに使用可能なファセット検索選択肢
    #
    # @return [Result::Options]
    #
    def facet_options
      @include_class.facet_options @filter
    end

  end
end
