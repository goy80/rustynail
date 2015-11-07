# coding: utf-8

require "rustynail/result/direction"


module Rustynail::Result
  class Base

    attr :data, :direction

    def initialize opt={}
      @data = opt[ :data ].presence || []
      direction = opt[ :direction ].presence || ""
      @direction = Direction.new( direction )
    end

  end
end
