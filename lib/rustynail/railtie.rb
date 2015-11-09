module Rustynail
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'rustynail' do |_app|
      Rustynail::Hooks.init
    end
  end
end
