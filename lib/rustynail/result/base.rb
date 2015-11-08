# coding: utf-8

require "rustynail/result/direction"
require "rustynail/result/options"


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
