When /^I fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    step %{I fill in "#{name}" with "#{value}"}
  end
end

When /^I fill in "([^"]*)" with "([^"]*)"$/ do |field, value|
  fill_in(field, :with => value)
end

When /^I select "(.*?)" as the "(.*?)"$/ do |selection, field|
  find(:css, "select[id*='card_#{field}']").select(selection)
end

When /^I press "(.*?)"$/ do |button_name|
  click_button(button_name)
end
