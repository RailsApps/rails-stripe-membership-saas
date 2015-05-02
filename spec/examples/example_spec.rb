RSpec.configure do |config|
  config.expect_with :rspec
  config.mock_framework = :rspec
end

describe 5 do
  it "is greater than 4" do
    expect(5).to be > 4
  end
end

describe "mocking with RSpec" do
  it "passes when it should" do
    user = double('user')
    expect(user).to receive(:message)
    user.message
  end
end