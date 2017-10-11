Plan.class_eval do

  def interval_enum
    {
        'daily' => 'day',
        'monthly' => 'month',
        'yearly' => 'year',
        'week' => 'week',
        '3-month' => 'every 3 months',
        '6-month' => 'every 6 months',
    }
  end

  rails_admin do
    weight 810
    navigation_label 'Administration'

    list do
      field :name
      field :amount
      field :interval
      field :stripe_id
      field :created_at
    end

    edit do
      field :name
      field :amount
      field :interval
      field :stripe_id
    end
  end

end
