module StripeHelper

  class Response
    def self.new(stripe_response)
      stripe_response_file = JSON.parse(IO.read("spec/support/fixtures/#{stripe_response}.json"))
      StripeHelper::NestedOstruct.new(stripe_response_file)
    end
  end

  class NestedOstruct
    def self.new(hash)
      OpenStruct.new(hash.inject({}){|r,p| r[p[0]] = p[1].kind_of?(Hash) ?
                                     NestedOstruct.new(p[1]) : p[1]; r })
    end
  end

end
