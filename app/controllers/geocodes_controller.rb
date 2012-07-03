# -*- coding: utf-8 -*-
require 'csv'
require 'lib/string.rb'
require 'lib/constants.rb'
require 'lib/search.rb'

class GeocodesController < ApplicationController

  def create

  	@key = params[:key] || nil
    @output = params[:output] 
    @query = params[:address] || nil
    @number = params[:number] || nil
    @street = params[:street] || nil
    @city_district = params[:city_district] || nil
    @neighborhood = params[:neighborhood] || nil
    @settlement = params[:settlement] || nil
    @district = params[:district] || nil
    @region = params[:region] || nil

    # Run authentication code for key
    render 'fail.xml' if @key != 'jeff'

    if @query
      @weight, @result = search(@query)
    else
      @weight, @result = precision_search('house_number' => @number,
                                          'street' => @street,
                                          'official_neighborhood' => @neighborhood,
                                          'city_district' => @city_district,
                                          'settlement' => @settlement,
                                          'district' => @district,
                                          'region' => @region)
    end

    if @result == nil
      render 'fail.xml'
      puts params
      puts "THIS IS HTE END"
      return
    end

    puts "ASDADASFNALSFNLKASNFLKASNMFLKAMSNF\n\n\n\n\n\n\n"
    puts @result.class
    if @result.class == Address
      render 'address.xml'
      return
    elsif @result.class == Street
      #render :json => Hash.from_xml(render_to_string('street.xml')).to_json
      render 'street.xml'
      return
    elsif @result.class == Settlement || @result.class == District || @result.class == Region || @result.class == CityDistrict || @result.class == OfficialNeighborhood
      render 'locale.xml'
      return
    else
      render 'fail.xml'
      puts "THIS IS THE OTHER END"
      return
    end

  end

end