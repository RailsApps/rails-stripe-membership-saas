class Plan < ActiveRecord::Base
  include Payola::Plan

  has_many :users

  def redirect_path(subscription)
    '/'
  end

end
