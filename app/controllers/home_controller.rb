class HomeController < ApplicationController

	def index
		find_top
	end

	private

	def find_top
		listings = []
		@listings = []
		Follow.all.each do |f|
			if f.followable_type == "Intangible" then listings << f.followable_id end 
		end
		listings = find_top_5 listings
		listings.each do |l|
			@listings << Listing.find(l)
		end
	end

	def find_top_5 list
		count = Hash.new(0)
		list.each {|element| count[element] += 1}
		list = list.uniq.sort {|x,y| count[y] <=> count[x]}
		list[0...6]
	end
end
