require 'gotenberg/helpers/action_view'
require 'gotenberg/helpers/vite_helpers'

module WillPaginate
  class Railtie < Rails::Railtie
    initializer "gotenberg.register" do |app|
      ActiveSupport.on_load :action_view do
        include Gotenberg::Helpers::ActionView
        include Gotenberg::Helpers::ViteHelpers
      end
    end
  end
end
