# -*- coding: utf-8 -*-
require 'csv'
require 'lib/string.rb'
require 'lib/constants.rb'
require 'lib/search.rb'

class SearchesController < ApplicationController

  def index
    @searches = Search.order('updated_at DESC').limit(30)
    @search = Search.new

    respond_to do |format|
      format.html
    end
  end

  def show
    @search = Search.find(params[:id])
    @searches = Search.order('updated_at DESC').limit(30)

    respond_to do |format|
      format.html
    end
  end

  def create
    @search = Search.new(params[:search])
    @weight, @result = search(@search.term.dup)

    #gc = Geocoder.coordinates('rustaveli ave, tbilisi, georgia')
    puts "________________________________"
    #puts gc[0]
    #puts gc.ll.class
    puts "________________RIGHT________________"

    if @result.class == Address
      @search.result = "#{@result.number} #{@result.street.full_name_en}, #{@result.street.settlement.name_en}, Georgia"
    elsif @result.class == Street
      @search.result = "#{@result.full_name_en}, #{@result.settlement.name_en}, Georgia"
    elsif @result.class == Settlement || @result.class == District || @result.class == Region || @result.class == CityDistrict || @result.class == OfficialNeighborhood
      @search.result = "#{@result.name_en}, Georgia"
    else
      @search.result = 'ERROR FINDING LOCATION'
    end

    respond_to do |format|
      if @search.save
        format.js { render 'load_search.js.erb'}
        #format.xml { redirect_to @result}
        format.html { redirect_to searches_path, :notice => 'Search was successfully created.' }
        #format.json { render :json => @search, :status => :created, :location => @search }
      else
        format.html { redirect_to searches_path }
        #format.json { render :json => @search.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @search = Search.find(params[:id])
    @search.destroy

    puts "WE ARE HERE________________________________________"

    respond_to do |format|
      format.html { redirect_to searches_path }
      format.json { head :no_content }
    end
  end

  def do_it
    puts "WE DID IT"
    respond_to do |format|
      format.js { render 'do_it.js.erb' }
    end
  end

  def how_to
    respond_to do |format|
      format.html
    end
  end

end