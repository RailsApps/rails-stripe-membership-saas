module Api
  module V1
    class ItemsController < ApplicationController
      before_filter :restrict_access
      respond_to :json
      
      def index
        respond_with Item.all
      end
      
      def show
        respond_with Item.find(params[:id])
      end
      
      def create
        respond_with Item.create(params[:item])
      end
      
      def update
        respond_with Item.update(params[:id], params[:item])
      end
      
      def destroy
        respond_with Item.destroy(params[:id])
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