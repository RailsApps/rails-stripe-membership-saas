class CreatePlanService
  def call
    platinum = Plan.where(name: 'Platinum').first_or_initialize do |p|
      p.amount = 2900
      # p.currency = 'usd'
      p.interval = 'month'
      p.stripe_id = 'platinum'
    end
    platinum.save!(validate: false)
    gold = Plan.where(name: 'Gold').first_or_initialize do |p|
      p.amount = 1900
      # p.currency = 'usd'
      p.interval = 'month'
      p.stripe_id = 'gold'
    end
    gold.save!(validate: false)
    silver = Plan.where(name: 'Silver').first_or_initialize do |p|
      p.amount = 900
      # p.currency = 'usd'
      p.interval = 'month'
      p.stripe_id = 'silver'
    end
    silver.save!(validate: false)
  end
end
