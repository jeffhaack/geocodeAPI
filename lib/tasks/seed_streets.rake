# encoding: utf-8
require 'rubygems'
require 'csv'
require 'nokogiri'

desc 'seed regions, cities, etc down to streets in database'

  task :seed_streets => [:environment] do
      #############################
      # Load the Regions from CSV #
      #############################
      csvFile = "#{Rails.root}/lib/tasks/seed_data/region.csv"
      @results = CSV.read(csvFile)
      @results.shift
      puts "Loading Regions..."
      @results.each do |r|
        newRegion = Region.new(:name_en => r[1], :name_ka => r[0].force_encoding("UTF-8"), :lat => Float(r[3]), :lon => Float(r[2]))
        newRegion.save unless Region.find_by_name_en(r[1])
      end

      ###############################
      # Load the Districts from CSV #
      ###############################
      csvFile = "#{Rails.root}/lib/tasks/seed_data/district.csv"
      @results = CSV.read(csvFile)
      @results.shift
      puts "Loading Districts..."
      @results.each do |r|
        name_en = r[3]
        name_ka = r[2]
        lat = r[5]
        lon = r[4]
        region_en = r[1]
        newDistrict = District.new(:name_en => name_en, :name_ka => name_ka, :lat => Float(lat), :lon => Float(lon))
        newDistrict.save unless District.find_by_name_en(name_en)
        region = Region.find_by_name_en(region_en)
        region.districts << newDistrict
      end

      ####################################################
      # Load the Cities from CSV, into Settlements table #
      ####################################################
      csvFile = "#{Rails.root}/lib/tasks/seed_data/city.csv"
      @results = CSV.read(csvFile)
      @results.shift
      puts "Loading Cities..."
      @results.each do |r|
        name_en = r[1]
        name_ka = r[0].force_encoding("UTF-8")
        lat = r[5]
        lon = r[4]
        region_en = r[7]
        district_en = r[9]
        newCity = Settlement.new(:name_en => name_en, :name_ka => name_ka, :lat => Float(lat), :lon => Float(lon))
        newCity.save unless Settlement.find_by_name_en(name_en)
        region = Region.find_by_name_en(region_en)
        region.settlements << newCity
        district = District.find_by_name_en(district_en)
        district.settlements << newCity
      end

      #########################################################
      # Load the Settlements from CSV, into Settlements table #
      #########################################################
      csvFile = "#{Rails.root}/lib/tasks/seed_data/settlement.csv"
      @results = CSV.read(csvFile)
      @results.shift
      puts "Loading Settlements..."
      @results.each do |r|
        name_en = r[1]
        name_ka = r[2]
        lat = r[7]
        lon = r[6]
        region_en = r[4]
        district_en = r[5]
        newSettlement = Settlement.new(:name_en => name_en, :name_ka => name_ka, :lat => Float(lat), :lon => Float(lon))
        newSettlement.save unless Settlement.find_by_name_en(name_en)
        region = Region.find_by_name_en(region_en)
        region.settlements << newSettlement
        district = District.find_by_name_en(district_en)
        district.settlements << newSettlement
      end

      ####################################
      # Load the City Districts from CSV #
      ####################################
      csvFile = "#{Rails.root}/lib/tasks/seed_data/cityDistrict.csv"
      @results = CSV.read(csvFile)
      @results.shift
      puts "Loading City Districts..."
      @results.each do |r|
        name_en = r[0]
        name_ka = r[4]
        lat = r[2]
        lon = r[1]
        city_en = 'Tbilisi'
        region_en = 'Tbilisi'
        district_en = 'Tbilisi'
        newCityDistrict = CityDistrict.new(:name_en => name_en, :name_ka => name_ka, :lat => Float(lat), :lon => Float(lon))
        newCityDistrict.save unless CityDistrict.find_by_name_en(name_en)
        region = Region.find_by_name_en(region_en)
        region.city_districts << newCityDistrict
        district = District.find_by_name_en(district_en)
        district.city_districts << newCityDistrict
        settlement = Settlement.find_by_name_en(city_en)
        settlement.city_districts << newCityDistrict
      end

      ############################################
      # Load the Official Neighborhoods from CSV #
      ############################################
      csvFile = "#{Rails.root}/lib/tasks/seed_data/officialNeighborhood.csv"
      @results = CSV.read(csvFile)
      @results.shift
      puts "Loading Official Neighborhoods..."
      @results.each do |r|
        name_en = r[0]
        name_ka = r[3]
        lat = r[2]
        lon = r[1]
        city_district_en = r[4]
        city_en = 'Tbilisi'
        region_en = 'Tbilisi'
        district_en = 'Tbilisi'
        newNeighborhood = OfficialNeighborhood.new(:name_en => name_en, :name_ka => name_ka, :lat => Float(lat), :lon => Float(lon))
        newNeighborhood.save unless OfficialNeighborhood.find_by_name_en(name_en)
        region = Region.find_by_name_en(region_en)
        region.official_neighborhoods << newNeighborhood
        district = District.find_by_name_en(district_en)
        district.official_neighborhoods << newNeighborhood
        settlement = Settlement.find_by_name_en(city_en)
        settlement.official_neighborhoods << newNeighborhood
        city_district = CityDistrict.find_by_name_en(city_district_en)
        city_district.official_neighborhoods << newNeighborhood
      end

      #########################
      # Load Streets from GML #
      #########################
      class StreetImport
        attr_accessor   :full_name_en,
                :full_name_ka,
                  :base_name_en,
                  :base_name_ka,
                  :suffix_en,
                  :suffix_ka,
                  :street_type_en,
                  :street_type_ka,
                  :centroid_lon,
                  :centroid_lat,
                  :wkt_linestring,
                  :official_neighborhood,
                  :city_district,
                  :city,
                  :district,
                  :region

        def initialize()
        end
      end

      # Schemas for two GML files
      STREETS_TBILISI = { 'title' => "ogr:streets_tbilisi",
                'name_en' => "ogr:Name_EN",
                'name_ka' => "ogr:Name_KA",
                'city_district' => "ogr:NAME_EN_1",
                'official_neighborhood' => "ogr:En_Name",
                'city' => "ogr:CITY_EN",
                'district' => nil,
                'region' => nil }

      STREETS_OTHER = {   'title' => "ogr:streets_other",
                'name_en' => "ogr:Name_EN",
                'name_ka' => "ogr:Name_KA",
                'city_district' => nil,
                'official_neighborhood' => nil,
                'city' => "ogr:Name_EN_1",
                'district' => "ogr:Distr_Eng",
                'region' => "ogr:Region_Eng" }

      def load_streets_gml(filename)
        f = File.open("#{Rails.root}/lib/tasks/seed_data/#{filename}")
        doc = Nokogiri::XML(f)

        gml_map = case filename
          when 'streets_tbilisi.gml'    then String::STREETS_TBILISI
          when 'streets_other.gml'    then String::STREETS_OTHER
          else String::STREETS_TBILISI
        end

        streets = []

        street_type_en = { 'st' => 'Street',
              'highway' => 'Highway',
              'roadway' => 'Highway',
              'avenue' => 'Avenue',
              'aly' => 'Alley',
              'aghmarti' => 'Rise',
              'agmarti' => 'Rise',
              'rise' => 'Rise',
              'dr' => 'Drive',
              'lane' => 'Lane',
              'ln' => 'Lane',
              'square' => 'Square',
              'bridge' => 'Bridge',
              'khidi' => 'Bridge', }

        street_type_ka = { 
                  # Street
                  'ქუჩა' => 'ქუჩა',
                  'ქუცა' => 'ქუჩა',
                  'კუჩ' => 'ქუჩა',
                  'ქაჩა' => 'ქუჩა',
                  'ქიჩა' => 'ქუჩა',
                  # Highway
                  'გზატკეცილი' => 'გზატკეცილი',
                  # Avenue
                  'გამზირი' => 'გამზირი',
                  # Alley
                  'გასასვლელი' => 'გასასვლელი',
                  'გასახვევი' => 'გასასვლელი',
                  # Rise
                  'აღმართი' => 'აღმართი',
                  # Drive
                  'ჩიხი' => 'ჩიხი',
                  'ჩუხუ' => 'ჩიხი',
                  # Lane
                  'შესახვევი' => 'შესახვევი',
                  # Square
                  'მოედანი' => 'მოედანი', 
                  # Bridge
                  'ხიდი' => 'ხიდი',
        }

        street_type_match = {   'ქუჩა' => 'Street',
                    'გზატკეცილი' => 'Highway',
                    'გამზირი' => 'Avenue',
                    'გასასვლელი' => 'Alley',
                    'აღმართი' => 'Rise',
                    'ჩიხი' => 'Drive',
                    'შესახვევი' => 'Lane',
                    'მოედანი' => 'Square',
                    'ხიდი' => 'Bridge' }

        roman_numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII",
                  "XIV", "XV", "XVI", "XVI", "XVII", "XVIII", "XIX", "XX"]

        t = []

        #puts doc.class
        doc.xpath("//gml:featureMember").xpath(gml_map["title"]).each do |feature|
          s = StreetImport.new

          # Add in full names in to the object from the GML file
          s.full_name_en = feature.at_xpath(gml_map['name_en']).content
          s.full_name_ka = feature.at_xpath(gml_map['name_ka']).content
          name_en_temp = s.full_name_en.dup
          name_ka_temp = s.full_name_ka.dup

          # Now let's parse off the last terms of the string to try and match a street type
          street_type_temp = name_en_temp.split(' ').last
          street_type_en.each do |key,val|
            if street_type_temp.downcase == key
              s.street_type_en = val
              name_en_temp.gsub!(street_type_temp, '')
            end
          end
          # Same in Georgian
          street_type_temp = name_ka_temp.split(' ').last
          street_type_ka.each do |key,val|
            if street_type_temp == key
              s.street_type_ka = val
              name_ka_temp.gsub!(street_type_temp, '')
            end
          end
          # ------------------------------------------------------------------------ #
          # Now if the English and Georgian street types disagree, what do we do?
          # For now leave it alone
          # ------------------------------------------------------------------------ #

          # Now see if any of the end terms on the end are a roman numeral - these are common
          #  suffixes in the data, refering often to the number of a lane
          suffix_temp = name_en_temp.split(' ').last
          if roman_numerals.include?(suffix_temp)
            s.suffix_en = suffix_temp
            s.suffix_ka = suffix_temp
            name_en_temp.gsub!(suffix_temp, '')
            name_ka_temp.gsub!(suffix_temp, '')
          end

          # Hopefully what remains should be the base name of the street
          s.base_name_en = name_en_temp
          s.base_name_ka = name_ka_temp

          # Get the coordinates from the GML file and turn into WKT linestring; also determine the middle point
          # and enter as centroid, even though technically it's not a "centroid"
          #LINESTRING(0 0, 10 10, 20 25, 50 60)
          coordinates = feature.element_children()[0].content().split(' ')
          linestring = ""
          coordinates.each do |coord|
            temp = coord.split(',')
            linestring += "#{temp[0]} #{temp[1]}, "
          end
          s.wkt_linestring = linestring.chop.chop
          # And the midpoint
          midpoint = coordinates.count / 2
          temp = coordinates[midpoint].split(',')
          s.centroid_lon = temp[0]
          s.centroid_lat = temp[1]

          # Get the information about where the street is
          s.city_district = feature.at_xpath(gml_map['city_district']).content unless gml_map['city_district'] == nil
          s.official_neighborhood = feature.at_xpath(gml_map['official_neighborhood']).content unless gml_map['official_neighborhood'] == nil
          s.city = feature.at_xpath(gml_map['city']).content unless gml_map['city'] == nil

          # And the district and region:
          if gml_map['district']
            s.district = feature.at_xpath(gml_map['district']).content
          else
            s.district = "Tbilisi"
          end
          if gml_map['region']
            s.region = feature.at_xpath(gml_map['region']).content
          else
            s.region = "Tbilisi"
          end

          streets << s

          puts s.full_name_en
          puts s.full_name_ka
          puts s.base_name_en
          puts s.base_name_ka
          puts s.suffix_en
          puts s.suffix_ka
          puts s.street_type_en
          puts s.street_type_ka
          puts s.wkt_linestring
          puts s.centroid_lon
          puts s.centroid_lat
          puts s.city_district
          puts s.official_neighborhood
          puts s.city
          puts s.district
          puts s.region

          newStreet = Street.new
          newStreet.full_name_en = s.full_name_en.strip unless s.full_name_en == nil
          newStreet.full_name_ka = s.full_name_ka.strip unless s.full_name_ka == nil
          newStreet.base_name_en = s.base_name_en.strip unless s.base_name_en == nil
          newStreet.base_name_ka = s.base_name_ka.strip unless s.base_name_ka == nil
          newStreet.suffix_en = s.suffix_en
          newStreet.suffix_ka = s.suffix_ka
          newStreet.street_type_en = s.street_type_en
          newStreet.street_type_ka = s.street_type_ka
          newStreet.wkt_linestring = s.wkt_linestring
          newStreet.lon = s.centroid_lon
          newStreet.lat = s.centroid_lat
          puts "Street #{s.base_name_en} saved to database" if newStreet.save

          puts "Adding Street #{s.base_name_en} to region #{s.region}"
          region = Region.find_by_name_en(s.region)
          region.streets << newStreet

          puts "Adding Street #{s.base_name_en} to district #{s.district}"
          district = District.find_by_name_en(s.district)
          district.streets << newStreet

          puts "Adding Street #{s.base_name_en} to settlement #{s.city}"
          settlement = Settlement.find_by_name_en(s.city)
          settlement.streets << newStreet

          if s.city_district
            puts "Adding Street #{s.base_name_en} to city district #{s.city_district}"
            city_district = CityDistrict.find_by_name_en(s.city_district)
            city_district.streets << newStreet
          end

          if s.official_neighborhood
            puts "Adding Street #{s.base_name_en} to neighborhood #{s.official_neighborhood}"
            neighborhood = OfficialNeighborhood.find_by_name_en(s.official_neighborhood)
            neighborhood.streets << newStreet
          end

          puts "_________________________________________________"

        end


      end

      load_streets_gml('streets_tbilisi.gml')
      load_streets_gml('streets_other.gml')
   end