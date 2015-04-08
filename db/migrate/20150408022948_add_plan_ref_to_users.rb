class AddPlanRefToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :plan, index: true, foreign_key: true
  end
end
