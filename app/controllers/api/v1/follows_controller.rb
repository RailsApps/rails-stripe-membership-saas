module Api
  module V1
    class FollowsController < ApplicationController
      # before_filter :restrict_access
      respond_to :json
      
      def index
        respond_with Follow.all
      end
      
      def show
        # respond_with Follow.find(params[:id])
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

      def get_urls
          @follow_urls = []

          Organization.where("url IS NOT NULL").each do |r|
                @follow_urls.push(r.url)
          end

          Follow.all.each do |f|
            if f.followable_type == "Item" 
              Item.find(f.followable_id).listings.each do |p|
                @follow_urls.push(p.url)
              end
            elsif f.followable_type == "Taxonomy"

            elsif f.followable_type == "Organization"

            end
          end

        respond_to do |format|
          format.json { render json: @follow_urls.uniq.to_json }
        end
      end

      private
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end
    end
  end
end