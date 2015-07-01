module StripeHelper

  class Response
    begin
      def self.new(stripe_response)
        stripe_response_file = JSON.parse(IO.read("spec/support/fixtures/#{stripe_response}.json").freeze)
        StripeHelper::NestedOstruct.new(stripe_response_file)
      end
    rescue Stripe::CardError => e  
        # Will any Stripe error be caught in this method above ?
        body = e.json_body
        err = body[:error]
        
        puts "Status is: #{e.http_status}"
        puts "Type is: #{err[:type]}"
        puts "Code is: #{err[:code]}" 
        # param is '' in this case 
        puts "Param is: #{err[:param]}" 
        puts "Message is: #{err[:message]}" 
      rescue Stripe::InvalidRequestError => e 
        # Invalid parameters were supplied to Stripe's API 
      rescue Stripe::AuthenticationError => e 
        # Authentication with Stripe's API failed 
        # (maybe you changed API keys recently) 
      rescue Stripe::APIConnectionError => e 
        # Network communication with Stripe failed 
      rescue Stripe::StripeError => e 
        # Display a very generic error to the user, and maybe send # yourself an email 
      rescue => e 
        # Something else happened, completely unrelated to Stripe 
    end
  end

  class NestedOstruct
    begin
      def self.new(hash)
        OpenStruct.new(hash.inject({}){|r,p| r[p[0]] = p[1].kind_of?(Hash) ? NestedOstruct.new(p[1]) : p[1]; r })
    rescue Stripe::CardError => e 
        # Will any Stripe error will be caught?
        body = e.json_body
        err = body[:error]
        
        puts "Status is: #{e.http_status}"
        puts "Type is: #{err[:type]}"
        puts "Code is: #{err[:code]}" 
        # param is '' in this case 
        puts "Param is: #{err[:param]}" 
        puts "Message is: #{err[:message]}" 
      rescue Stripe::InvalidRequestError => e 
        # Invalid parameters were supplied to Stripe's API 
      rescue Stripe::AuthenticationError => e 
        # Authentication with Stripe's API failed 
        # (maybe you changed API keys recently) 
      rescue Stripe::APIConnectionError => e 
        # Network communication with Stripe failed 
      rescue Stripe::StripeError => e 
        # Display a very generic error to the user, and maybe send # yourself an email 
      rescue => e 
        # Something else happened, completely unrelated to Stripe 
    end

    end
  end

end