class StreetsController < ApplicationController
  # GET /streets
  # GET /streets.json
  def index
    #@streets = Street.all
    #@streets = Street.order('full_name_en ASC').limit(500)
    @streets = Street.find_all_by_settlement_id(74)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @streets }
    end
  end

  # GET /streets/1
  # GET /streets/1.json
  def show
    @street = Street.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @street }
    end
  end

  # GET /streets/new
  # GET /streets/new.json
  def new
    @street = Street.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @street }
    end
  end

  # GET /streets/1/edit
  def edit
    @street = Street.find(params[:id])
  end

  # POST /streets
  # POST /streets.json
  def create
    @street = Street.new(params[:street])

    respond_to do |format|
      if @street.save
        format.html { redirect_to @street, :notice => 'Street was successfully created.' }
        format.json { render :json => @street, :status => :created, :location => @street }
      else
        format.html { render :action => "new" }
        format.json { render :json => @street.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /streets/1
  # PUT /streets/1.json
  def update
    @street = Street.find(params[:id])

    respond_to do |format|
      if @street.update_attributes(params[:street])
        format.html { redirect_to @street, :notice => 'Street was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @street.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /streets/1
  # DELETE /streets/1.json
  def destroy
    @street = Street.find(params[:id])
    @street.destroy

    respond_to do |format|
      format.html { redirect_to streets_url }
      format.json { head :ok }
    end
  end
end
