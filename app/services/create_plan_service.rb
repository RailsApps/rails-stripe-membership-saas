class CreatePlanService
  def call
    Plan.where(name: 'StartUp').first_or_create do |p|
      p.amount = 1900
      p.interval = 'month'
      p.stripe_id = 'start-up'
    end
    Plan.where(name: 'Growth').first_or_create do |p|
      p.amount = 4900
      p.interval = 'month'
      p.stripe_id = 'growth'
    end
    Plan.where(name: 'Premium').first_or_create do |p|
      p.amount = 9900
      p.interval = 'month'
      p.stripe_id = 'premium'
    end
  end
end
