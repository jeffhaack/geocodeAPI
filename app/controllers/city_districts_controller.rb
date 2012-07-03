class CityDistrictsController < ApplicationController
  # GET /city_districts
  # GET /city_districts.json
  def index
    @city_districts = CityDistrict.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @city_districts }
    end
  end

  # GET /city_districts/1
  # GET /city_districts/1.json
  def show
    @city_district = CityDistrict.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @city_district }
    end
  end

  # GET /city_districts/new
  # GET /city_districts/new.json
  def new
    @city_district = CityDistrict.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @city_district }
    end
  end

  # GET /city_districts/1/edit
  def edit
    @city_district = CityDistrict.find(params[:id])
  end

  # POST /city_districts
  # POST /city_districts.json
  def create
    @city_district = CityDistrict.new(params[:city_district])

    respond_to do |format|
      if @city_district.save
        format.html { redirect_to @city_district, :notice => 'City district was successfully created.' }
        format.json { render :json => @city_district, :status => :created, :location => @city_district }
      else
        format.html { render :action => "new" }
        format.json { render :json => @city_district.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /city_districts/1
  # PUT /city_districts/1.json
  def update
    @city_district = CityDistrict.find(params[:id])

    respond_to do |format|
      if @city_district.update_attributes(params[:city_district])
        format.html { redirect_to @city_district, :notice => 'City district was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @city_district.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /city_districts/1
  # DELETE /city_districts/1.json
  def destroy
    @city_district = CityDistrict.find(params[:id])
    @city_district.destroy

    respond_to do |format|
      format.html { redirect_to city_districts_url }
      format.json { head :ok }
    end
  end
end
