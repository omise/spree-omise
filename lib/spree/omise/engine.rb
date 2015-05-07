module Spree
  module Omise
    class Engine < ::Rails::Engine
      engine_name "spree-omise"

      isolate_namespace Spree::Omise

      initializer "spree.spree-omise.payment_methods", :after => "spree.register.payment_methods" do |app|
        app.config.spree.payment_methods << Spree::Gateway::Omise
      end
    end
  end
end
