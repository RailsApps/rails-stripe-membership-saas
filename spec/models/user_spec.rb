describe User do

  let(:user) { FactoryGirl.create(:user) }

  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(@user.email).to match 'test@example.com'
  end

  it "should create a new instance given a valid attribute" do
    @user.email = 'valid@example.com'
    expect(@user.save!).to be_valid
  end

  it "should require an email address" do
    expect((@user.email = "").save).to_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      expect((@user.email = address).save).to be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      excpect((@user.email = address).save).to_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    @user.save
    expect(FactoryGirl.create(:user)).to_not be_valid
  end

  it "should reject email addresses identical up to case" do
    @user.save
    expect(FactoryGirl.create(:user, email: :'example@example.com'.upcase)).to_not be_valid
  end
end

describe "Passwords" do

  let(:user) { FactoryGirl.build(:user) }

  it "should have a password attribute" do
    expect(@user).to respond_to(:password)
    end

  it "should have a password confirmation attribute" do
    expect(@user).to respond_to(:password_confirmation)
  end
end

describe "password validations" do

  let(:user) { FactoryGirl.build(:user) }

  it "should require a password" do
    expect((@user.password = "").save).to_not be_valid
  end

  it "should require a matching password confirmation" do
    original_user_password = @user.password
    @user.password = "different"
    @user.save
    expect(@user.password).to_not eq original_user_password
  end

  it "should reject short passwords" do
    short = "a" * 5
    expect((@user.password = short).save).to_not be_valid
  end
end

describe "password encryption" do

  let(:user) { FactoryGirl.create(:user) }

  it "should have an encrypted password attribute" do
    expect(@user.save).to respond_to(:encrypted_password)
  end

  it "should set the encrypted password attribute" do
    expect(@user.encrypted_password).to_not be_blank
  end
end

describe "expire" do

  let(:user) { FactoryGirl.build(:user) }

  it "sends an email to user" do
    @user.save
    @user.expire
    expect(ActionMailer::Base.deliveries.last.to).to eq @user.email
  end
end

describe "#update_plan" do

  let(:user) { FactoryGirl.build(:user) }
  let(:user1) { FactoryGirl.build(:user, role: :'2') }
  let(:user2) { FactoryGirl.build(:user, role: :'3') }

  it "updates a users role" do
    @user.save
    expect(@user.role).to eq ""
    @user1.save
    expect(@user.role).to eq 'silver'
    @user1.update_plan(@user1.role = 2)
    expect(@user.role).tl eq "gold"
  end

  it "will not remove original role from database" do
    pending "is memberships set up to allow multiple roles ? no."
    @user.update_plan(@role2)
    Role.all.count.should == 2
  end
end

describe ".update_stripe" do
  context "with a non-existing user" do

    before do
      successful_stripe_response = StripeHelper::Response.new("success")
      Stripe::Customer.stub(:create).and_return(successful_stripe_response)
      @user = FactoryGirl.build(:user, email: :"test@testign.com", stripe_token: 12345, password: :'changeme', password_confirmation: :'changeme')
      @user.role = "silver"
    end

    it "creates a new user with a succesful stripe response" do
      @user.save!
      new_user = User.last
      expect(new_user.customer_id).to eq("youAreSuccessful")
      expect(new_user.stripe_token).to be_nil
    end
  end
end