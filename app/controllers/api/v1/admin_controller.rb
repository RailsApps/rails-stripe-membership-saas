module Api
  module V1
    class AdminController < ApplicationController
      before_filter :restrict_access
      respond_to :json

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
            elsif f.followable_type == "Intangible"
              listing = Listing.find(f.followable_id)
              @follow_urls.push(listing.url)
            elsif f.followable_type == "Category"

            end
          end

        respond_to do |format|
          format.json { render json: @follow_urls.uniq.to_json }
        end
      end

      def create
        params.delete(:format)
        params.delete(:action)
        params.delete(:controller)
        params.delete(:access_token)


        if params[:url] && params[:name] && params[:image]
          create_listing params
        else
          create_unknown params
        end

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

      def create_listing params
          # ListingWorker.perform_async(params)
          listing = Listing.find_or_initialize_by_listing_id(:listing_id => params[:id],
                                                             :url => params[:url],
                                                             :name => params[:name],
                                                             :image => params[:image],
                                                             :desc => params[:description])

          Unknown.find_by_listing_id(:listing_id => params[:id]).delete rescue nil
          uri = URI.parse(params[:url])

          params.delete(:id)
          params.delete(:url)
          params.delete(:name)
          params.delete(:image)
          params.delete(:description)
          
          listing.organization = Organization.find_or_create_by_name(:name => params[:site_name],
                                                                     :url => "#{uri.scheme}://#{uri.host}")
          params.delete(:site_name)

          tags = params[:tags].split(',')
          tags.each do |tag|
            t = Tag.find_or_create_by_name(tag)
            listing.taxonomies << t rescue nil
          end
          params.delete(:tags)
          
          categories = params[:categories].split(',')
          categories.each_with_index do |category, index|
            ap index
            c = Category.find_or_initialize_by_name(category)
            c.subcategories << Category.find_or_create_by_name(categories[index+1]) rescue nil
            listing.taxonomies << c rescue nil
            c.save
          end
          params.delete(:categories)

          listing.fields.merge!(params)

          listing.save
        end

        def create_unknown params
          # UnkownWorker.perform_async(params)
          ap params
          unknown = Unknown.find_or_initialize_by_listing_id(:listing_id => params[:id],
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
          
          unknown.fields.merge!(params)

          unknown.save
        end
    end
  end
end