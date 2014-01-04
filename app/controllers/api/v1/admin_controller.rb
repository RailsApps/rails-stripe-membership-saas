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
            if f.followable_type == "Category"

            elsif f.followable_type == "Intangible"
              listing = Listing.find(f.followable_id)
              @follow_urls.push(listing.url)
            elsif f.followable_type == "Item" 
              Item.find(f.followable_id).listings.each do |p|
                @follow_urls.push(p.url)
              end
            end
          end

        respond_to do |format|
          format.json { render json: @follow_urls.uniq.to_json }
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
          # ListingWorker.perform_async(params)
          create_listing params
        else
          # UnkownWorker.perform_async(params)
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
          listing = Listing.find_or_initialize_by_listing_id(:listing_id => params[:id],
                                                             :url => params[:url],
                                                             :image => params[:image])
          listing.name = params[:name][0..254] rescue nil
          listing.desc = params[:description][0..254] rescue nil
          # u = Unknown.find_by_listing_id(:listing_id => params[:id])
          # u.delete rescue nil

          params.delete(:id)
          params.delete(:url)
          params.delete(:name)
          params.delete(:image)
          params.delete(:description)
          
          listing.organization = Organization.find_or_create_by_name(:name => params[:site_name],
                                                                     :url => params[:site_url])
          params.delete(:site_name)
          params.delete(:site_url)

          categories = params[:categories].split(',') rescue []
          categories.each_with_index do |category, index|
            next_element = categories[index+1]
            c = Category.find_or_initialize_by_name(category)
            # if t = Tag.find_by_name(category)
            #   t.make_category
            # end
            if next_element
              c.subcategories << Category.find_or_create_by_name(next_element) rescue nil
            end
            listing.taxonomies << c rescue nil
            if index == 0 then c.parent_id = nil end
            c.save
          end
          params.delete(:categories)

          tags = params[:tags].split(',') rescue []
          tags.each do |tag|
                t = Tag.find_or_create_by_name(tag)
                listing.taxonomies << t rescue nil
          end
          params.delete(:tags)
          
          params.each do |key, value|
            if value.blank? then params.delete(key) end
          end

          # if params[:sameAs]
          #   # item = Item.
          # end
          # params.delete(:sameAs)

          listing.fields.merge!(params)

          listing.save   
        end

        def create_unknown params
          unknown = Unknown.find_or_initialize_by_listing_id(:listing_id => params[:id],
                                                             :url => params[:url],
                                                             :image => params[:image])
          unknown.name = params[:name][0..254] rescue nil
          unkonwn.desc = params[:description][0..254] rescue nil
          params.delete(:id)
          params.delete(:url)
          params.delete(:name)
          params.delete(:image)
          params.delete(:description)
          
          listing.organization = Organization.find_or_create_by_name(:name => params[:site_name],
                                                                     :url => params[:site_url])
          params.delete(:site_name)
          params.delete(:site_url)
          
          unknown.fields.merge!(params)

          unknown.save
        end
    end
  end
end