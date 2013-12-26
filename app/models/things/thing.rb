class Thing < ActiveRecord::Base
  # The most generic type of item.
  attr_accessible :additionalType, 
  				  :desc, 
  				  :name, 
  				  :url, 
  				  :image,
  				  :sameAs
  self.abstract_class = true
end
