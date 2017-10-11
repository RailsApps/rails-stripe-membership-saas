Plan.class_eval do

  rails_admin do
    weight 810
    navigation_label 'Administration'

    edit do
      field :name
      field :amount
      field :interval
      field :stripe_id
    end
  end

end
