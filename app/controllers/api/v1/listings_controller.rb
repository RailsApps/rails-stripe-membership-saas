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
        params.delete(:format)
        params.delete(:action)
        params.delete(:controller)
        params.delete(:access_token)

        if params[:url] && params[:name] && params[:image]
          listing = Listing.find_or_initialize_by_listing_id(:listing_id => params[:id],
                                                             :url => params[:url],
                                                             :name => params[:name],
                                                             :image => params[:image],
                                                             :desc => params[:description])
          params.delete(:id)
          params.delete(:url)
          params.delete(:name)
          params.delete(:image)
          params.delete(:description)
          
          listing.organization = Organization.find_by_name(params[:site_name])
          params.delete(:site_name)
          
          categories = params[:categories].split(',')
          categories.each_with_index do |category, index|
            ap index
            c = Category.find_or_initialize_by_name(category)
            c.subcategories << Category.find_or_create_by_name(categories[index+1]) rescue nil
            listing.taxonomies << c rescue nil
            c.save
          end
          params.delete(:categories)

          tags = params[:tags].split(',')
          tags.each do |tag|
            t = Tag.find_or_initialize_by_name(tag)
            listing.taxonomies << t rescue nil
            t.save
          end
          params.delete(:tags)
          
          listing.fields.merge!(params)

          listing.save
        else
          unknown = Unknown.find_or_initialize_by_unknown_id(:unknown_id => params[:id],
                                                             :url => params[:url],
                                                             :name => params[:name],
                                                             :image => params[:image],
                                                             :desc => params[:description])
          params.delete(:id)
          params.delete(:url)
          params.delete(:name)
          params.delete(:image)
          params.delete(:description)
          
          unknown.organization = Organization.find_by_name(params[:site_name])
          params.delete(:site_name)
          
          categories = params[:categories].split(',')
          categories.each_with_index do |category, index|
            ap index
            c = Category.find_or_initialize_by_name(category)
            c.subcategories << Category.find_or_create_by_name(categories[index+1]) rescue nil
            unknown.taxonomies << c rescue nil
            c.save
          end
          params.delete(:categories)

          tags = params[:tags].split(',')
          tags.each do |tag|
            t = Tag.find_or_initialize_by_name(tag)
            unknown.taxonomies << t rescue nil
            t.save
          end
          params.delete(:tags)
          
          unknown.fields.merge!(params)

          unknown.save
        end
        
        respond_to do |format|
          msg = { :status => "ok", :message => "Success!", :html => "" }
          format.json  { render :json => msg }
        end
      end
      
      def update
        respond_with Listing.update(params[:id], params[:listing_id])
      end
      
      def destroy
        respond_with Listing.destroy(params[:id])
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