module Api
  module V1
    class ListingsController < ApplicationController
      before_filter :restrict_access
      respond_to :json
      
      def index
        respond_with Listing.all
      end
      
      def show
        respond_with Listing.find(params[:id])
      end
      
      def create
        # respond_with Listing.create(params[:listing_id])
      end
      
      def update
        # respond_with Listing.update(params[:id], params[:listing_id])
      end
      
      def destroy
        # respond_with Listing.destroy(params[:id])
      end

      private
      
      def restrict_access
        if params[:access_token]
          if params[:access_token] == ENV['RAILS_SECRET_KEY'] then return true end
          head :unauthorized
        else
          authenticate_or_request_with_http_token do |token, options|
            ApiKey.exists?(access_token: token) || token == ENV['RAILS_SECRET_KEY']
          end
        end
      end
    end
  end
end