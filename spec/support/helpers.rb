require 'support/helpers/session_helpers'
RSpec.configure do |config|
  config.include Requests::SessionHelpers, type: :request
end