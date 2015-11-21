# coding: utf-8

require "rustynail/result/direction"
require "rustynail/result/options"

#
# ファセット検索結果オブジェクト。
#
# メンバー
# list: 検索結果
# options: ファセット検索条件
# direction: 検索結果ソート順。
#
module Rustynail::Result
  class Base

    attr :list, :options, :direction

    def initialize opt={}
      @list = opt[ :list ].presence || []
      @options = opt[ :options ].presence || Options.new( {} )
      @direction = opt[ :direction ].presence || Direction.new( "" )
    end

  end
end
