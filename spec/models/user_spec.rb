describe User do

  after(:each) do
    Warden.test_reset!
  end

  let(:user) { FactoryGirl.build(:user) }

  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(user.email).to match 'test@example.com'
  end

  it "should create a new instance given a valid attribute" do
    user.email = 'valid@example.com'
    expect(user.save).to be true
  end

  it "should require an email address" do
    expect(user.email = "").not_to be true
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
    expect(user.email = address).to be_truthy
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
    invalid_email_user = User.new(email: address)
    expect(invalid_email_user).not_to be_valid
    end
  end

  it "should reject duplicate email addresses" do
    user.save
    expect(User.new(email: 'test@example.com')).not_to be_valid
  end

  it "should reject email addresses identical up to case" do
    user.save
    expect(FactoryGirl.create(:user, email: :'example@example.com'.upcase)).not_to be_invalid
  end
end

describe "Passwords" do

  let(:user) { FactoryGirl.build(:user) }

  it "should have a password attribute" do
    expect(user).to respond_to(:password)
    end

  it "should have a password confirmation attribute" do
    expect(user).to respond_to(:password_confirmation)
  end
end

describe "password validations" do

  let(:user) { FactoryGirl.build(:user) }

  it "should require a password" do
    user.password = ""
    expect(user.save).not_to be_truthy
  end

  it "should require a matching password confirmation" do
    original_user_password = user.password
    user.password = "different"
    user.save
    expect(user.password).not_to eq original_user_password
  end

  it "should reject short passwords" do
    short = "a" * 5
    user.password = short
    expect(user.save).not_to be_truthy
  end
end

describe "password encryption" do

  let(:user) { FactoryGirl.build(:user) }

  it "should have an encrypted password attribute" do
    expect(user).to respond_to(:encrypted_password)
  end

  it "should set the encrypted password attribute" do
    expect(user.encrypted_password).not_to be_blank
  end
end

describe "expire" do
  
  let(:user) { FactoryGirl.build(:user) }

  it "sends an email to user" do
    pending 'for future use, not testing email yet'
    user.save
    user.expire
    expect(ActionMailer::Base.deliveries.last.to).to eq user.email
  end
end