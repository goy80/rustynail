# coding: utf-8

module Rustynail
  class ConfigGenerator < ::Rails::Generators::Base
    source_root File.expand_path( File.join( File.dirname(__FILE__), 'templates' ) )

    desc <<-EOS
    Description:
      Copies rustynail configuration file to your application's initailizer directory.
    EOS

    def copy_config_file
      template "rustynail_config.rb", "config/initializers/rustynail_config.rb"
    end

  end
end
