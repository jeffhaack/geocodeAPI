xml.instruct! :xml, :version=>"1.0", :encoding => 'ISO-8859-1'
xml.xml :version => "1.0", "xmlns" => "http://maps.kartulia.com/api" do

  xml.Response do
    xml.Place do 
      xml.Address do
        xml.Address_EN @result.number + @result.street.full_name_en + ', ' + @result.street.settlement.name_en + ', Georgia'
        xml.Address_KA @result.street.full_name_ka + ' ' + @result.number + ', ' + @result.street.settlement.name_ka + ', საქართველო'
      end

        xml.AddressDetails do
          xml.Country do
            xml.Country_EN 'Georgia'
            xml.Country_KA 'საქართველო'
          end

        if @result.street.region != nil
            xml.Region do
              xml.Region_EN @result.street.region.name_en
              xml.Region_KA @result.street.region.name_ka
            end
          end

          if @result.street.district != nil
            xml.District do
              xml.District_EN @result.street.district.name_en
              xml.District_KA @result.street.district.name_ka
            end
          end

          if @result.street.settlement != nil
            xml.Settlement do
              xml.Settlement_EN @result.street.settlement.name_en
              xml.Settlement_KA @result.street.settlement.name_ka
            end
          end

          if @result.street.city_district != nil
          xml.CityDistrict do
            xml.CityDistrict_EN @result.street.city_district.name_en
              xml.CityDistrict_KA @result.street.city_district.name_ka
            end
          end

          if @result.street.official_neighborhood != nil
            xml.Neighborhood do
            xml.Neighborhood_EN @result.street.official_neighborhood.name_en
              xml.Neighborhood_KA @result.street.official_neighborhood.name_ka
            end
          end

          if @result.street.full_name_en != nil || @result.full_name_ka != nil
            xml.Thoroughfare do
              xml.StreetName_en @result.street.full_name_en if @result.street.full_name_en != nil
              xml.StreetName_ka @result.street.full_name_ka if @result.street.full_name_ka != nil
            end
          end
        end

        xml.Point do
          xml.coordinates "#{@result.lon}, #{@result.lat}"
        end

      end
  end

end