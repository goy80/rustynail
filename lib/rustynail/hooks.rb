module Rustynail
  class Hooks
    def self.init
      ActiveSupport.on_load(:action_view) do
        ::ActionView::Base.send :include, Rustynail::ActionViewExtension
      end
    end
  end
end
