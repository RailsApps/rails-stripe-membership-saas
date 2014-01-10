module Api
  module V1
    class AdminController < ApplicationController
     # before_filter :restrict_access
      respond_to :json

      def get_follow_urls
          time ||= Time.zone.now.beginning_of_day
          @follow_urls = []

          Organization.where("url IS NOT NULL").each do |r|
                @follow_urls.push(r.url)
          end

          Follow.all.each do |f|
            if f.followable_type == "Category"

            elsif f.followable_type == "Intangible"
              listing = Listing.find(f.followable_id)
              if listing.updated_at < time
                @follow_urls.push(listing.url)
              end
            elsif f.followable_type == "Item" 
              Item.find(f.followable_id).listings.each do |p|
                if listing.updated_at < time
                  @follow_urls.push(p.url)
                end
              end
            end
          end

        respond_to do |format|
          format.json { render json: @follow_urls.uniq.to_json }
        end
      end

      def get_all_urls
          @all_urls = []

          listings = Listing.where("updated_at < ?", Time.zone.now.beginning_of_day).sort_by {|obj| obj.organization}.reverse!
          listings.each do |l|
            @all_urls.push(l.url)
          end

        respond_to do |format|
          format.json { render json: @all_urls.uniq.to_json }
        end
      end

      def create 
        require 'uri'
        params.delete(:format)
        params.delete(:action)
        params.delete(:controller)
        params.delete(:access_token)
        uri = URI.parse(params[:url])
        params[:site_url] = "#{uri.scheme}://#{uri.host}"

        if params[:url] && params[:name] && params[:image]
          Resque.enqueue(ListingWorker, params) 
        else
          Resque.enqueue(UnknownWorker, params) 
        end

        respond_to do |format|
          msg = { :status => "ok", :message => "Success!", :html => "" }
          format.json  { render :json => msg }
        end
      end

      def remove_listing_fields
        Resque.enqueue(RemoveListFieldWorker, params[:fields]) 

        respond_to do |format|
          msg = { :status => "ok", :message => "Success!", :html => "" }
          format.json  { render :json => msg }
        end
      end

      def match_listings
        Resque.enqueue(MatchListingsWorker, params[:fields]) 

        respond_to do |format|
          msg = { :status => "ok", :message => "Success!", :html => "" }
          format.json  { render :json => msg }
        end
      end

      private
      
      def restrict_access
        if params[:access_token]
          if params[:access_token] == ENV['RAILS_SECRET_KEY'] then return true end
          head :unauthorized
        else
          authenticate_or_request_with_http_token do |token, options|
            token == ENV['RAILS_SECRET_KEY']
          end
        end
      end
    end
  end
end
