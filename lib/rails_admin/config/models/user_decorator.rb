User.class_eval do

  rails_admin do |c|
    weight 810
    navigation_label 'Administration'

    list do
      field :id
      field :email
      field :plan
      field :role
      field :created_at
    end

    edit do
      field :email
      field :password
      field :password_confirmation
      field :role do
        visible { bindings[:object] != bindings[:controller].current_user }
      end
      field :plan
    end

  end

end
