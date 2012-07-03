class OfficialNeighborhoodsController < ApplicationController
  # GET /official_neighborhoods
  # GET /official_neighborhoods.json
  def index
    @official_neighborhoods = OfficialNeighborhood.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @official_neighborhoods }
    end
  end

  # GET /official_neighborhoods/1
  # GET /official_neighborhoods/1.json
  def show
    @official_neighborhood = OfficialNeighborhood.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @official_neighborhood }
    end
  end

  # GET /official_neighborhoods/new
  # GET /official_neighborhoods/new.json
  def new
    @official_neighborhood = OfficialNeighborhood.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @official_neighborhood }
    end
  end

  # GET /official_neighborhoods/1/edit
  def edit
    @official_neighborhood = OfficialNeighborhood.find(params[:id])
  end

  # POST /official_neighborhoods
  # POST /official_neighborhoods.json
  def create
    @official_neighborhood = OfficialNeighborhood.new(params[:official_neighborhood])

    respond_to do |format|
      if @official_neighborhood.save
        format.html { redirect_to @official_neighborhood, :notice => 'Official neighborhood was successfully created.' }
        format.json { render :json => @official_neighborhood, :status => :created, :location => @official_neighborhood }
      else
        format.html { render :action => "new" }
        format.json { render :json => @official_neighborhood.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /official_neighborhoods/1
  # PUT /official_neighborhoods/1.json
  def update
    @official_neighborhood = OfficialNeighborhood.find(params[:id])

    respond_to do |format|
      if @official_neighborhood.update_attributes(params[:official_neighborhood])
        format.html { redirect_to @official_neighborhood, :notice => 'Official neighborhood was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @official_neighborhood.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /official_neighborhoods/1
  # DELETE /official_neighborhoods/1.json
  def destroy
    @official_neighborhood = OfficialNeighborhood.find(params[:id])
    @official_neighborhood.destroy

    respond_to do |format|
      format.html { redirect_to official_neighborhoods_url }
      format.json { head :ok }
    end
  end
end
