module Api
  module V1
    class FollowsController < ApplicationController
      before_filter :restrict_access
      respond_to :json
      
      def index
        respond_with Follow.all
      end
      
      def show
        respond_with Follow.find(params[:id])
      end
      
      def create
        # respond_with Follow.create(params[:id])
      end
      
      def update
        # respond_with Follow.update(params[:id], params[:id])
      end
      
      def destroy
        # respond_with Follow.destroy(params[:id])
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