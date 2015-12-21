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
    # @param [ Hash ] opts
    # @option opts [ Hash ] :filter 選択された検索条件。
    # @option opts [ ActiveRecord::Relation ] :list 検索結果。
    # @option opts [ Result::Options ] :facet_options: 検索結果の絞込みに使えるファセット検索選択肢。
    # @option opts [ Result::Direction ] :direction 検索結果のソート順オブジェクト。
    #
    def initialize( opts={} )
      @filter = opts[ :filter ] || {}
      @list = opts[ :list ].presence || []
      @facet_options = opts[ :facet_options ].presence || Options.new( {} )
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
      @filter[ column.to_sym ] == option
    end

  end
end
