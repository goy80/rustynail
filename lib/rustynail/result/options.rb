# coding: utf-8

module Rustynail::Result
  class Options

    def initialize opt = {}
      @opt = opt
    end

    def to_h
      @opt
    end

  end
end

