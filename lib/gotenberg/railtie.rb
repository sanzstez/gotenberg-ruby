require 'gotenberg/helpers/action_view'

module WillPaginate
  class Railtie < Rails::Railtie
    initializer "gotenberg.register" do |app|
      ActiveSupport.on_load :action_view do
        include Gotenberg::Helpers::ActionView
      end
    end
  end
end