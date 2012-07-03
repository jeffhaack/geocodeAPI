xml.instruct! :xml, :version=>"1.0", :encoding => 'ISO-8859-1'
xml.xml :version => "1.0", "xmlns" => "http://api.kartulia.com/maps" do

	xml.Response do
		xml.Place do 
			xml.Address do
				xml.Address_EN @result.full_name_en + ', ' + @result.city.name_en + ', Georgia'
				xml.Address_KA @result.full_name_ka + ', ' + @result.city.name_ka + ', საქართველო'
			end

  			xml.AddressDetails do
	  			xml.Country do
	  				xml.Country_EN 'Georgia'
	  				xml.Country_KA 'საქართველო'
	  			end

				if @result.region != nil
	  				xml.Region do
	  					xml.Region_EN @result.region.name_en
	  					xml.Region_KA @result.region.name_ka
	  				end
	  			end

	  			if @result.district != nil
	  				xml.District do
	  					xml.District_EN @result.district.name_en
	  					xml.District_KA @result.district.name_ka
	  				end
	  			end

	  			if @result.city != nil
	  				xml.City do
	  					xml.City_EN @result.city.name_en
	  					xml.City_KA @result.city.name_ka
	  				end
	  			end

  				if @result.city_district != nil
					xml.CityDistrict do
						xml.CityDistrict_EN @result.city_district.name_en
	  					xml.CityDistrict_KA @result.city_district.name_ka
	  				end
  				end

  				if @result.official_neighborhood != nil
  					xml.Neighborhood do
						xml.Neighborhood_EN @result.official_neighborhood.name_en
  						xml.Neighborhood_KA @result.official_neighborhood.name_ka
  					end
  				end

  				if @result.full_name_en != nil || @result.full_name_ka != nil
  					xml.Thoroughfare do
	    				xml.StreetName_en @result.full_name_en if @result.full_name_en != nil
    					xml.StreetName_ka @result.full_name_ka if @result.full_name_ka != nil
    				end
    			end
    		end

    		xml.Point do
    			xml.coordinates "#{@result.centroid_lon}, #{@result.centroid_lat}"
    		end

    		xml.WKT_LineString @result.wkt_linestring

    	end
	end

end