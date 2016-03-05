class CreateUserService
  def call
    user2 = User.find_or_create_by(email: 'user2@example.com') do |user|
      user.password = 'please123'
      user.password_confirmation = 'please123'
      user.role = 'silver'
      user.plan_id = 1
    end
    user2.save!(validate: false)
    user3 = User.find_or_create_by(email: 'user3@example.com') do |user|
      user.password = 'please123'
      user.password_confirmation = 'please123'
      user.role = 'gold'
      user.plan_id = 2
    end
    user3.save!(validate: false)
    user4 = User.find_or_create_by(email: 'user4@example.com') do |user|
      user.password = 'please123'
      user.password_confirmation = 'please123'
      user.role = 'platinum'
      user.plan_id = 3
    end
    user4.save!(validate: false)
  end
end