#xml.instruct!
xml.xml :version => "1.0", "xmlns" => "http://api.kartulia.com/maps" do

	xml.Response do
		xml.Place do 
			xml.Address do
				xml.Address_EN @result.name_en + ', Georgia'
				xml.Address_KA @result.name_ka + ', საქართველო'
			end

  			xml.AddressDetails do
	  			xml.Country do
	  				xml.Country_EN 'Georgia'
	  				xml.Country_KA 'საქართველო'
	  			end

	  			if @result.class == Region
	  				xml.Region do
		  				xml.Region_EN @result.name_en
		  				xml.Region_KA @result.name_ka
		  			end
		  		elsif @result.region != nil
	  				xml.Region do
	  					xml.Region_EN @result.region.name_en
	  					xml.Region_KA @result.region.name_ka
	  				end
		  		end

		  		if @result.class == District
	  				xml.District do
  						xml.District_EN @result.name_en
  						xml.District_KA @result.name_ka
  					end
		  		elsif @result.class != Region && @result.district != nil
		  			xml.District do
		  				xml.District_EN @result.district.name_en
		  				xml.District_KA @result.district.name_ka
		  			end
		  		end

		  		if @result.class == City
		  			xml.City do
	  					xml.City_EN @result.name_en
	  					xml.City_KA @result.name_ka
	  				end
		  		elsif @result.class != Region && @result.class != District && @result.city != nil
	  				xml.City do
	  					xml.City_EN @result.city.name_en
	  					xml.City_KA @result.city.name_ka
	  				end
		  		end

		  		if @result.class == CityDistrict
		  			xml.CityDistrict do
						xml.CityDistrict_EN @result.name_en
	  					xml.CityDistrict_KA @result.name_ka
	  				end
		  		elsif @result.class != Region && @result.class != District && @result.class != City && @result.class != CityDistrict && @result.city_district != nil
					xml.CityDistrict do
						xml.CityDistrict_EN @result.city_district.name_en
	  					xml.CityDistrict_KA @result.city_district.name_ka
	  				end
	  			end

				if @result.class == OfficialNeighborhood
					xml.Neighborhood do
						xml.Neighborhood_EN @result.name_en
  						xml.Neighborhood_KA @result.name_ka
  					end
	  			end

    		end

    		xml.Point do
    			xml.coordinates "#{@result.lon}, #{@result.lat}"
    		end

    	end
	end

end