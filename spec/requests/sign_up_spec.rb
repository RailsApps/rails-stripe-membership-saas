describe 'Sign Up', :devise, type: :request, js: true  do

  before(:each) do
    CreatePlanService.new.call
  end

  after(:each) do
    Warden.test_reset!
  end

  it "should be able to find a plan element" do
    plan_silver = Plan.find_by_name('Silver')
    plan_gold = Plan.find_by_name('Gold')
    plan_platinum = Plan.find_by_name('Platinum')
    expect(plan_silver.id).to eq 1
    expect(plan_gold.id).to eq 2
    expect(plan_platinum.id).to eq 3
    expect(plan_silver.id.class.to_s).to eq "Fixnum"
    expect(plan_gold.id.class.to_s).to eq "Fixnum"
    expect(plan_platinum.id.class.to_s).to eq "Fixnum"
    visit "/users/sign_up?plan=platinum"
    expect(page).to have_xpath("//body")
    expect(page).to have_selector(".authform")
    expect(page).to have_selector('select#user_plan_id')
    expect(page).to have_select('user_plan_id', selected: 'Platinum')
  end

  it "should not be able to find a non-existing element" do
    visit "/users/sign_up?plan=platinum"
    within('select#user_plan_id') do
      expect(page).not_to have_select('Titanium')
    end
  end

  it "should not be able to find a successful sign up message" do
    visit "/users/sign_up?plan=platinum"
    click_button "Sign up"
    expect(page).not_to have_content("Welcome! You have signed up successfully.")
  end

  it "should notify user when something is wrong with card number" do
    visit "/users/sign_up?plan=silver"
    click_button "Sign up"
    expect(page).to have_content("This card number looks invalid.")
  end

  it 'allows visitor to sign up as a platinum subscriber' do
    @user = FactoryGirl.build(:user, email: 'platinum@example.com', password: 'letmesignup', password_confirmation: 'letmesignup')
    visit new_user_registration_path(plan: 'platinum')
    expect(page).to have_selector("select#user_plan_id")
    # user changes their mind on plan choice
    within('legend#select_user_plan_id') do
      select('Silver')
      sleep 1
      select('Gold')
      sleep 0.5
      select('Platinum')
    end
    plan_choice = find("select#user_plan_id").value
    @plan_id = plan_choice.to_s
    expect(plan_choice.class).to eq String
    expect(plan_choice.to_i).to eq 3
    expect(plan_choice).to eq 3.to_s
    expect(Plan.all.count).to eq 3
    sign_up(@user.email, @user.password, @user.password_confirmation, @plan_id)
    expect(page).to have_content "Welcome! You have signed up successfully."
  end

end