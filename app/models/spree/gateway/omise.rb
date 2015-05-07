module Spree
  class Gateway::Omise < Gateway
    preference :secret_key, :string
    preference :public_key, :string
    preference :currency, :string, :default => 'THB'

    CC_MAPPING = {
      'MasterCard' => 'master',
      'Visa' => 'visa'
    }

    def method_type
      'omise' # so, it will render _omise.html.erb
    end

    def auto_capture?
      true
    end

    def provider_class
      ActiveMerchant::Billing::OmiseGateway
    end

    def payment_profiles_supported?
      true
    end

    def purchase(money, creditcard, gateway_options)
      provider.purchase(
        *options_for_purchase_or_authorize(money, creditcard, gateway_options)
      )
    end

    def authorize(money, creditcard, gateway_options)
      provider.authorize(
        *options_for_purchase_or_authorize(money, creditcard, gateway_options)
      )
    end

    def capture(money, charge_id, gateway_options)
      provider.capture(money, charge_id, gateway_options)
    end

    def credit(money, charge_id, gateway_options)
      provider.refund(money, charge_id, {})
    end

    def void(charge_id, gateway_options)
      provider.void(charge_id, {})
    end

    def cancel(charge_id, gateway_options)
      provider.void(charge_id, {})
    end

    def create_profile(payment)
      return nil unless payment.source.gateway_customer_profile_id.nil?
      options = {}
      options[:email] = payment.order.email if payment.order.email
      creditcard      = update_source!(payment.source)
      if creditcard.number.blank? && creditcard.gateway_payment_profile_id.present?
        options[:token_id] = creditcard.gateway_payment_profile_id
      end
      store_card(creditcard)
    end

    private

    def update_source!(payment)
      payment.source  = CC_MAPPING[payment.source.cc_type] if CC_MAPPING.include?(payment.source.cc_type)
      payment
    end

    def store_card(creditcard, options)
      response = provider.store(creditcard, options.merge(set_default_card: true))
      if response.success?
        creditcard.update_attributes(
          :gateway_customer_profile_id => response.params['id'], # the customer id
          :gateway_payment_profile_id  => response.params['default_card'] # the card id
        )
      else
        payment.send(:gateway_error, response)
      end
    end

    def options_for_purchase_or_authorize(money, creditcard, gateway_options)
      options = {}
      options[:description] = "(Spree) Order ID: #{gateway_options[:order_id]}"
      options[:currency]    = gateway_options[:currency]
      options[:ip]          = gateway_options[:ip]

      payment_profile_id = creditcard.gateway_payment_profile_id
      add_token_or_card(payment_profile_id)
      options[:customer_id] = creditcard.gateway_customer_profile_id unless options[:card_id].nil?
      creditcard = nil if options[:token_id] || options[:card_id]
      [money, creditcard, options]
    end

    def add_token_or_card(profile_id)
      return if profile_id.nil?
      options[:token_id] = profile_id if profile_id.match('^tokn')
      options[:card_id]  = profile_id if profile_id.match('^card')
    end

  end
end
