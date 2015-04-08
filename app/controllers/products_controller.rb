class ProductsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :identify_product

  def show
    send_file @path, :disposition => "attachment; filename=#{@file}"
  end

  private
  def identify_product
    valid_characters = "^[0-9a-zA-Z]*$".freeze
    unless params[:id].blank?
      @product_id = params[:id]
      @product_id = @product_id.tr("^#{valid_characters}", '')
    else
      raise "Filename missing"
    end
    unless params[:format].blank?
      @format = params[:format]
      @format = @format.tr("^#{valid_characters}", '')
    else
      raise "File extension missing"
    end
    @path = "app/views/products/#{@product_id}.#{@format}"
    @file = "#{@product_id}.#{@format}"
  end

end
