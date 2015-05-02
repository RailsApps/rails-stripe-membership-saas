class CreateUserService
  def call
    user4 = User.find_or_create_by(email: :'user4@example.com') do |user|
      user.password = 'please124'
      user.password_confirmation = 'please124'
      user.role = 'silver'
      user.plan_id = 1
    end
    user4.plan_id = 1
    user4.save!(:validate => false)
  end
end