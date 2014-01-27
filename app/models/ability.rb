# this entire CanCan file will be removed, replaced by app/policies of Pundit
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    else
      can :view, :silver if user.has_role? :silver
      can :view, :gold if user.has_role? :gold
      can :view, :platinum if user.has_role? :platinum
    end
  end
end