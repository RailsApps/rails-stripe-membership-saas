module ApplicationHelper
  # reference for next three methods
  # http://stackoverflow.com/questions/14866353/devise-sign-in-not-completing

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">X</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end
end