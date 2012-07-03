# -*- coding: utf-8 -*-

LOG = true  # set to true to output to logfile
LOG_FILE = 'search.log'

def search(str)
  logFile = File.new(LOG_FILE, "w") if LOG
  logFile.syswrite("Beginning search() method on string '#{str}'\n") if LOG

  # latinize, remove all punctiation other than dashes, and downcase
  pure_string = str.purify
  logFile.syswrite("Appling the purify() method to search string.  String is now '#{pure_string}'\n") if LOG

  # perform some latin morphing, split into an array, and perform some extra georgian morphing
  search_terms = pure_string.georgian_morph('extended').split(' ')
  logFile.syswrite("Latin morphing and splitting search term into array: [#{search_terms.join(', ')}]\n") if LOG

  # So we want to determine what to submit to precision search
  search_region = nil
  search_district = nil
  search_settlement = nil
  search_street = nil
  search_street_type = nil
  search_housenumber = nil

  search_string_alpha = Array.new
  search_string_zeta = Array.new
  search_string_alpha_streetless = Array.new

  if search_terms.count == 1
    weight, hit = precision_search('settlement' => search_terms[0])
    return weight, hit unless hit == nil
  end

  if has_street_type?(search_terms)
    # separate search_terms into before and after and ID the street type
    street_type = get_street_type(search_terms)
    search_street_type = street_type
    logFile.syswrite("The search terms appear to include a street type: #{street_type}\n") if LOG

    # algorithm to split the terms into two strings, separated by the type
    flag = false
    search_terms.each do |term|
      if term == street_type
        flag = true
        next
      end
      search_string_alpha << "#{term} " unless flag == true
      search_string_zeta << "#{term} " if flag == true
    end
    logFile.syswrite("The search has been split by the street type for further processing.\n") if LOG
    logFile.syswrite("The alpha terms are [#{search_string_alpha.join(', ')}] and the zeta terms are [#{search_string_zeta.join(', ')}]\n") if LOG
    logFile.syswrite("Now searching through alpha for street name hits\n") if LOG

    # go backwards through alpha and set first street matching hit as search_street and add any
    #  preceding terms that still hit street
    (search_string_alpha.length-1).downto(0) do |i|
      hits = Street.search(search_string_alpha[i])
      if hits.empty?
        next
      elsif i == 0
        logFile.syswrite("Hit:") if LOG
        hits.each do |h|
          logFile.syswrite("\t#{h.full_name_en}, #{h.settlement.name_en}, ID #{h.id}\n") if LOG
        end
        search_street = search_string_alpha[i]
        break
      else
        hits2 = Street.search(search_string_alpha[i-1] + ' ' + search_string_alpha[i])
        if hits2.empty?
          hits.each do |h|
            logFile.syswrite("\t#{h.full_name_en}, #{h.settlement.name_en}, ID #{h.id}\n") if LOG
          end
          search_street = search_string_alpha[i]
          search_string_alpha_streetless = search_string_alpha.dup
          search_string_alpha_streetless.delete_at(i)
          break
        elsif i == 1
          hits2.each do |h|
            logFile.syswrite("\t#{h.full_name_en}, #{h.settlement.name_en}, ID #{h.id}\n") if LOG
          end
          search_street = search_string_alpha[i-1] + ' ' + search_string_alpha[i]
          break
        else
          hits3 = Street.search(search_string_alpha[i-2] + ' ' + search_string_alpha[i-1] + ' ' + search_string_alpha[i])
          if hits3.empty?
            hits2.each do |h|
              logFile.syswrite("\t#{h.full_name_en}, #{h.settlement.name_en}, ID #{h.id}\n") if LOG
            end
            search_street = search_string_alpha[i-1] + ' ' + search_string_alpha[i]
            search_string_alpha_streetless = search_string_alpha.dup
            search_string_alpha_streetless.delete_at(i)
            search_string_alpha_streetless.delete_at(i-1)
            break
          else
            hits3.each do |h|
              logFile.syswrite("\t#{h.full_name_en}, #{h.settlement.name_en}, ID #{h.id}\n") if LOG
            end
            search_street = search_string_alpha[i-2] + ' ' + search_string_alpha[i-1] + ' ' + search_string_alpha[i]
            search_string_alpha_streetless = search_string_alpha.dup
            search_string_alpha_streetless.delete_at(i)
            search_string_alpha_streetless.delete_at(i-1)
            search_string_alpha_streetless.delete_at(i-2)
            break
          end
        end
      end
    end
    puts "Search Street: #{search_street}"
    puts "Alpha Streetless: #{search_string_alpha_streetless}"

    # disregard those and see if there are any numbers in alpha, if yes set as housenumber
    (search_string_alpha_streetless.length-1).downto(0) do |i|
      if is_housenumber?(search_string_alpha_streetless[i])
        search_housenumber = search_string_alpha_streetless[i]
        break
      end
    end
    puts "Housenumber: #{search_housenumber}"

    # if that doesn't work check zeta
    if search_housenumber == nil
      0.upto((search_string_zeta.length-1)) do |i|
        if is_housenumber?(search_string_zeta[i])
          search_housenumber = search_string_zeta[i]
          break
        end
      end
      puts "Housenumber: #{search_housenumber}"
    end

    # in zeta, go forward looking for city matches
    0.upto((search_string_zeta.length-1)) do |i|
      hits = Settlement.search(search_string_zeta[i])
      if hits.empty?
        next
      else
        search_settlement = search_string_zeta[i]
        break
      end
    end

    # submit just using street, street_type, number, and city
    precision_search('street' => search_street,
                     'street_type' => search_street_type,
                     'house_number' => search_housenumber,
                     'settlement' => search_settlement)

  else
    search_terms.each do |term|
      if is_housenumber?(term)
        search_housenumber = term
        break
      end
    end
    puts "Housenumber: #{search_housenumber}"


    poss_cities = match('locale', remove_unmatchable_terms(search_terms))
    poss_streets = []
    match('street', remove_unmatchable_terms(search_terms)).each do |s|
      flag = false
      poss_cities.each do |c|
        if s.include?(c)
          flag = true
        end
      end
      poss_streets << s unless flag
    end

    # Slight problem occurs if all the terms match a city name, cause then no city pops up...
    #  going to disregard for now...

    puts "-- Possible Streets --"
    puts poss_streets
    puts "-- Possible Streets --\n"
    puts "-- Possible Cities --"
    puts poss_cities
    puts "-- Possible Cities --"

    top_weight = 0
    hit = nil
    logFile_temp = File.new("TEMP_LOGFILE.txt", "w")
    poss_cities.each do |city|
      if poss_streets.empty?
        temp_weight, temp_hit = precision_search('settlement' => city)
        if temp_weight > top_weight
          hit = temp_hit
          top_weight = temp_weight
        end
      end
      poss_streets.each do |street|
        temp_weight, temp_hit = precision_search('street' => street, 'settlement' => city, 'house_number' => search_housenumber)
#        logFile_temp.syswrite("#{street}, #{city} - precision search reveals a weight of #{temp_weight} for #{temp_hit.full_name_en}, #{temp_hit.settlement.name_en}\n")
        if temp_weight > top_weight
          hit = temp_hit
          top_weight = temp_weight
        end
      end
    end
    logFile_temp.close
    puts top_weight
    return top_weight, hit

  end




end

# right now precision_search will return a string
###################### precision_search(params) #####################
# Valid parameters are
#   house_number
#   street
#   street_type
#   settlement
#   official_neighborhood
#   city_district
#   district
#   region

def precision_search(params)
  #############################
  ###### Set up Log File ######
  logFile = File.new("logfile.txt", "w")
  #############################

  4.times do puts "" end
  # Step 1 - Clean out the parameters to get rid of non-allowed ones and nil values
  params.delete_if {|key,value| key != 'house_number' && 
                                key != 'street' &&
                                key != 'street_type' &&
                                key != 'settlement' &&
                                key != 'official_neighborhood' &&
                                key != 'city_district' &&
                                key != 'district' &&
                                key != 'region' ||
                                value == nil}
  logFile.syswrite("Step 1 Completed Successfully - Cleared empty parameters and nil values\n")
  logFile.syswrite("Parameters submitted are #{params}\n")

  # Step 2 - Here we will normalize all the terms
  params.each do |key,value|
    lang = value.get_language
    params[key] = value.purify
    params[key] = params[key].georgian_morph('extended') if lang == 'ka'
    puts "#### Step 2 ####   #{value}"
  end
  logFile.syswrite("\nStep 2 Completed Successfully - Purified search terms\n")
  logFile.syswrite("Parameters are now are #{params}\n")

  # Step 3 - Let's get all the hits for each parameter, along with an implied weight,
  #  which is lessened by the distance between the supplied string and the one that it matches
  logFile.syswrite("\nProcessing Step 3... - (Get hits for each parameter and implied weights)\n")
  regionHits = Hash.new
  if params['region']
    hits = Region.search(params['region'])
    hits.each do |h|
      regionHits[h.id] = 20 - levenshtein(h.name_en, params['region'])
    end
    puts "Region Hits:"
    puts regionHits
    logFile.syswrite("Region Hits are #{regionHits}\n")
  end

  districtHits = Hash.new
  if params['district']
    hits = District.search(params['district'])
    hits.each do |h|
      districtHits[h.id] = 20 - levenshtein(h.name_en, params['district'])
    end
    puts "District Hits:"
    puts districtHits
    logFile.syswrite("District Hits are #{districtHits}\n")
  end

  cityDistrictHits = Hash.new
  if params['city_district']
    hits = CityDistrict.search(params['city_district'])
    hits.each do |h|
      cityDistrictHits[h.id] = 20 - levenshtein(h.name_en, params['city_district'])
    end
    puts "City District Hits:"
    puts cityDistrictHits
    logFile.syswrite("City District Hits are #{cityDistrictHits}\n")
  end

  officialNeighborhoodHits = Hash.new
  if params['official_neighborhood']
    hits = OfficialNeighborhood.search(params['official_neighborhood'])
    hits.each do |h|
      officialNeighborhoodHits[h.id] = 20 - levenshtein(h.name_en, params['official_neighborhood'])
    end
    puts "Official Neighborhood Hits:"
    puts officialNeighborhoodHits
    logFile.syswrite("Official Neighborhood Hits are #{officialNeighborhoodHits}\n")
  end

  settlementHits = Hash.new
  if params['settlement']
    hits = Settlement.search(params['settlement'])
    hits.each do |h|
      settlementHits[h.id] = 20 - levenshtein(h.name_en, params['settlement'])
    end
    puts "Settlement Hits:"
    4.times do puts "" end
    puts settlementHits
    4.times do puts "" end
    logFile.syswrite("Settlement Hits are #{settlementHits}\n")
  end

  streetHits = Hash.new
  if params['street']
    hits = Street.search(params['street'], :per_page => 2000)
    hits.each do |h|
      edits = levenshtein(h.full_name_en, params['street'])      
      streetHits[h.id] = 20 - edits unless edits > 20
    end
    puts "Street Hits:"
    4.times do puts "" end
    puts streetHits
    4.times do puts "" end
    logFile.syswrite("Street Hits are #{streetHits}\n")
  end


  # Step 4 - Determine what type of result the request is for:
  request_type = nil
  request_type = 'region' if params.has_key?('region')
  request_type = 'district' if params.has_key?('district')
  request_type = 'settlement' if params.has_key?('settlement')
  request_type = 'city_district' if params.has_key?('city_district')
  request_type = 'official_neighborhood' if params.has_key?('official_neighborhood')
  request_type = 'street' if params.has_key?('street')
  request_type = 'address' if params.has_key?('house_number')
  if request_type == nil
    logFile.syswrite("INVALID REQUEST - Can not determine request type")
    return false
  end
  puts "#### Step 4 #### Request is for a #{request_type}"
  puts "#### Step 4 ####   #{params}"
  logFile.syswrite("\nStep 4 Completed - Algorithm is looking for a #{request_type.upcase}")

  case request_type
  # Step 4a - If we're looking for a region
  when 'region'
    topWeight = 0
    topRegion = 0
    regionHits.each do |regionId, regionWeight|
      if regionWeight > topWeight
        topWeight = regionWeight
        topRegion = regionId
      end
    end
    puts "You have hit the region of #{Region.find_by_id(topRegion).name_en} with weight of #{topWeight}"
    logFile.syswrite("\nStep 4a Completed - We hit #{Region.find_by_id(topRegion).name_en} with weight of #{topWeight}\n")
    return topWeight, Region.find_by_id(topRegion)
  
  # Step 4b - If we're looking for a district
  when 'district'
    topWeight = 0
    topDistrict = 0
    districtHits.each do |districtId, districtWeight|
      current_weight = districtWeight
      
      regionHits.each do |regionId, regionWeight|
          current_weight += regionWeight if District.find_by_id(districtId).region.id == regionId
      end

      if current_weight > topWeight
        topWeight = current_weight
        topDistrict = districtId
      end
    end
    puts "You have hit the district of #{District.find_by_id(topDistrict).name_en} with weight of #{topWeight}"
    logFile.syswrite("\nStep 4b Completed - We hit #{District.find_by_id(topDistrict).name_en} with weight of #{topWeight}\n")
    return topWeight, District.find_by_id(topDistrict)

  # Step 4c - If we're looking for a settlement
  when 'settlement'
    topWeight = 0
    topSettlement = 0
    settlementHits.each do |settlementId, settlementWeight|
      current_weight = settlementWeight
      
      districtHits.each do |districtId, districtWeight|
        current_weight += districtWeight if Settlement.find_by_id(settlementId).district.id == districtId
      end
      
      regionHits.each do |regionId, regionWeight|
          current_weight += regionWeight if Settlement.find_by_id(settlementId).region.id == regionId
      end

      if current_weight > topWeight
        topWeight = current_weight
        topSettlement = settlementId
      end
    end

    begin
      logFile.syswrite("\nStep 4c Completed - We hit #{Settlement.find_by_id(topSettlement).name_en} with a weight of #{topWeight}\n")
    rescue
      puts "oops"
    end

    return topWeight, Settlement.find_by_id(topSettlement)

  # Step 4d - If we're looking for a city district - assumes Tbilisi since no other settlements have districts
  when 'city_district'
    topWeight = 0
    topCityDistrict = 0
    cityDistrictHits.each do |cityDistrictId, cityDistrictWeight|
      if cityDistrictWeight > topWeight
        topWeight = cityDistrictWeight
        topCityDistrict = cityDistrictId
      end
    end
    puts "You have hit the city district of #{CityDistrict.find_by_id(topCityDistrict).name_en} with weight of #{topWeight}"
    logFile.syswrite("\nStep 4d Completed - We hit #{CityDistrict.find_by_id(topCityDistrict).name_en} with weight of #{topWeight}\n")
    return topWeight, CityDistrict.find_by_id(topCityDistrict)

  # Step 4e - If we're looking for an official neighborhood
  when 'official_neighborhood'
    topWeight = 0
    topOfficialNeighborhood = 0
    officialNeighborhoodHits.each do |officialNeighborhoodId, officialNeighborhoodWeight|
      current_weight = officialNeighborhoodWeight

      cityDistrictHits.each do |cityDistrictId, cityDistrictWeight|
          current_weight += cityDistrictWeight if OfficialNeighborhood.find_by_id(officialNeighborhoodId).city_district.id == cityDistrictId
      end

      if current_weight > topWeight
        topWeight = current_weight
        topOfficialNeighborhood = officialNeighborhoodId
      end
    end
    puts "You have hit the neighborhood of #{OfficialNeighborhood.find_by_id(topOfficialNeighborhood).name_en} with weight of #{topWeight}"
    logFile.syswrite("\nStep 4e Completed - We hit #{OfficialNeighborhood.find_by_id(topOfficialNeighborhood).name_en} with weight of #{topWeight}\n")
    return topWeight, OfficialNeighborhood.find_by_id(topOfficialNeighborhood)

  # Step 4f - If we're looking for a street or address
  when 'street', 'address'
    topWeight = 0
    topStreet = 0

    # Assign settlement to Tbilisi if its empty - Should not do it this way, just a temp fix
    if settlementHits.empty?
      settlementHits[74] = 5
    end

    if streetHits.empty?
      logFile.syswrite("\nStep 4f Completed - Unable to match any streets\n")
      return false
    end

    streetHits.each do |streetId, streetWeight|
      current_weight = streetWeight
      settlementHits.each do |settlementId, settlementWeight|
        current_weight += settlementWeight if Street.find_by_id(streetId).settlement.id == settlementId
      end
      
      districtHits.each do |districtId, districtWeight|
        current_weight += districtWeight if Street.find_by_id(streetId).district.id == districtId
      end
      
      regionHits.each do |regionId, regionWeight|
          current_weight += regionWeight if Street.find_by_id(streetId).region.id == regionId
      end

      if current_weight > topWeight
        topWeight = current_weight
        topStreet = streetId
      end
    end

    if topStreet == 0
      logFile.syswrite("\nStep 4f Completed - Something wrong with weighting\n")
      return false
    end

    puts "Top street is ID #{topStreet} aka #{Street.find_by_id(topStreet).full_name_en} with a weight of #{topWeight}"
    if request_type == 'street'
      logFile.syswrite("\nStep 4f Completed - We hit #{Street.find_by_id(topStreet).full_name_en}, #{Street.find_by_id(topStreet).settlement.name_en} with a weight of #{topWeight}\n")
      return topWeight, Street.find_by_id(topStreet)
    else
      addys = Street.find_by_id(topStreet).addresses.collect {|x| x.number}
      # if there's an exact address match return it
      if addys.include?(params['house_number'])
        return topWeight + 10, Address.find_by_street_id_and_number(topStreet,params['house_number'])
      # return the address number on found street closest to submitted number
      else
        return topWeight + 4, Address.find_by_street_id_and_number(topStreet, closestAddress(params['house_number'], addys))
      end
    end

  end
end

# Returns the closest actual address object to the numbers in an array
def closestAddress(number, possible_numbers)
  stripped_number = number.to_i
  diff = 10000
  closest = nil
  possible_numbers.each do |possible|
    poss = possible.to_i
    if poss - stripped_number < diff && poss - stripped_number >= 0
      diff = poss - stripped_number
      closest = possible
    elsif stripped_number - poss < diff && stripped_number - poss >= 0
      diff = stripped_number - poss
      closest = possible
    end
  end
  return closest
end

# Takes an array of terms and returns an array of terms matching strings in STREET_TYPES
def get_street_type(terms)
  s_t_terms = []
  terms.each do |term|
    STREET_TYPE_MAP.each do |poss, act|
        s_t_terms << term if term == poss
    end
  end
  return s_t_terms.last
end

def is_street_type?(term)
  STREET_TYPE_MAP.each do |possible, actual|
    return true if term == possible
  end
  return false
end

def has_street_type?(search_terms)
  search_terms.each do |st|
    return true if is_street_type?(st)
  end
  return false
end

def is_housenumber?(str)
  digit_count = 0
  letter_count = 0
  for i in 0..str.length-1
    if str[i] =~ /[0-9]/
      digit_count += 1
    elsif str[i] =~ /[A-Za-z]/
      letter_count += 1
    end
  end
  (digit_count < 4 && letter_count < 3 && letter_count < digit_count) ? true : false
end

# Takes two arrays and deletes all the terms in terms2 from terms1
def remove_terms(terms1, terms2)
  if terms2.class == Array
    terms2.each do |termRemove|
      ##### May update this not to remove if the first term or remove more than one #####
      terms1.delete(termRemove)
    end
  else
    terms1.delete(terms2)
  end
  terms1
end

# Try to match each term individually, and if they don't match anything, remove from expression
def remove_unmatchable_terms(terms)
  terms_class = terms.class
  terms = terms.split(' ') if terms_class == String

  terms_to_remove = []
  terms.each do |term|
    count = ThinkingSphinx.search_count(term)
    if count == 0
      terms_to_remove << term
    end
    #######
    ### Get rid of Roman Numerals
    temp = term.dup
    temp.gsub!(/[ixv]/,'')
    if temp == ''
      terms_to_remove << term
    end
    #######
  end
  remove_terms(terms, terms_to_remove)

  terms_class == String ? terms.join(' ') : terms
end

# Returns an array of matched names in the desired model
def match(table, search_terms)
  names = []
  hits = []
  case table
  when 'locale'
    search_terms.each do |term|
      hits = Settlement.search(:conditions => {:name => term})
      hits.each do |h|
        puts "MMM #{h.name_en}"
        names << h.name_en unless names.include?(h.name_en)
      end
      hits = OfficialNeighborhood.search(:conditions => {:name => term})
      hits.each do |h|
        puts "MMM #{h.name_en}"
        names << h.name_en unless names.include?(h.name_en)
      end
      hits = CityDistrict.search(:conditions => {:name => term})
      hits.each do |h|
        puts "MMM #{h.name_en}"
        names << h.name_en unless names.include?(h.name_en)
      end
      hits = District.search(:conditions => {:name => term})
      hits.each do |h|
        puts "MMM #{h.name_en}"
        names << h.name_en unless names.include?(h.name_en)
      end
      hits = Region.search(:conditions => {:name => term})
      hits.each do |h|
        puts "MMM #{h.name_en}"
        names << h.name_en unless names.include?(h.name_en)
      end
    end
  when 'street'
    search_terms.each do |term|
      hits = Street.search(:conditions => {:name => term}, :per_page => 2000)
      hits.each do |h|
        puts "OOO #{h.full_name_en}"
        names << h.full_name_en unless names.include?(h.full_name_en)
      end
    end
  end
  puts names
  return names
end
