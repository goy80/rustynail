# coding: utf-8

require "active_support/configurable"

module Rustynail

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :column_name_converter
    config_accessor :option_name_converter


    config_accessor :sort_option_converter
    config_accessor :facet_max
    config_accessor :qs_filter_name
    config_accessor :search_action_name
  end

  def self.config
    @config
  end

  def self.configure( &block )
    yield @config ||= Rustynail::Configuration.new
  end

  # デフォルト値
  configure do | config |
    config.column_name_converter = nil
    config.option_name_converter = nil
    config.sort_option_converter = nil
    config.facet_max = -1
    config.qs_filter_name = :filter
    config.search_action_name = :search
  end

end

