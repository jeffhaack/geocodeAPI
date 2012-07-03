# -*- coding: utf-8 -*-

def search_location(search_string)
  puts "#######################################################################"
  puts "##########################  Processing search #########################"
  puts "#######################################################################"
  puts "search_string: #{search_string}"
  # latinize, remove all punctiation other than dashes, and downcase
  pure_string = search_string.purify
  puts "pure_string: #{pure_string}"
  # perform some latin morphing, split into an array, and perform some extra georgian morphing
  search_terms = pure_string.georgian_morph('extended').split(' ')
  puts "search_terms: #{search_terms.join(', ')}"

  # test if there is a Street Type in the search terms
  if has_street_type?(search_terms)
    result = search_with_street_type(search_terms)
    return result if result
  # or if there is no street_type
  else
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

    puts "--"
    puts poss_streets
    puts "--"
    city_search_bool = booleanize(poss_cities)
    street_search_bool = booleanize(poss_streets)

    #poss_cities << "Tbilisi" if poss_cities.empty? # well, need to think about other regions

    unless poss_cities.empty? || poss_streets.empty?
      result_matches = Street.search :conditions => {:name => street_search_bool,
                                                     :settlement => city_search_bool,
                                                     :street_type => 'Street'},
                                                     :match_mode => :boolean,
                                                     :sort_mode => :extended,
                                                     :order => "@weight DESC"
      return result_matches.first if not result_matches.empty?

      # I think this should work, but it's not reindexing right for some reason...
      result_matches = ThinkingSphinx.search :conditions => {:name => city_search_bool},
                                                     :match_mode => :boolean,
                                                     :sort_mode => :extended,
                                                     :order => "@weight DESC"
      return result_matches.first if not result_matches.empty?
      ####

      #return poss_cities.first + '-AHA'
    end

    # If can't match a street name
    # Search everything, but only the name field, which will leave streets out
    result_matches = ThinkingSphinx.search :conditions => {:name => remove_unmatchable_terms(search_terms)}, :sort_mode => :extended, :order => "@weight DESC"
    return result_matches.first unless result_matches.empty?
    
  end

  return nil
end

# Returns a boolean string to search for using Sphinx from passed array
def booleanize(poss_names)
  bool_string = "('"
  poss_names.each do |n|
    bool_string += " (#{n}) |"
  end
  bool_string.chop!
  bool_string += "')"
  puts "bool_string: #{bool_string}"
  return bool_string
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
  return names
end



def search_with_street_type(search_terms)
  # separate search_terms into before and after and ID the street type
    street_type = get_street_type(search_terms)
    puts "street_type: #{street_type}"
    # algorithm to split the terms into two strings, separated by the type
    search_string_alpha = ''
    search_string_zeta = ''
    flag = false
    search_terms.each do |term|
      if term == street_type
        flag = true
        next
      end
      search_string_alpha += "#{term} " unless flag == true
      search_string_zeta += "#{term} " if flag == true
    end
    puts "search_string_alpha: #{search_string_alpha}"
    puts "search_string_zeta: #{search_string_zeta}"
    
    # if there are no street matches we must return nil straight away
    street_matches = Street.search_count(:conditions => {:name => remove_unmatchable_terms(search_string_alpha)}, :match_mode => :any)
    return nil if street_matches == 0
    if street_matches > 0 && search_string_zeta.empty?
      search_string_zeta = 'Tbilisi'
    end
    # try an exact hit
    result_matches = Street.search :conditions => {:settlement => remove_unmatchable_terms(search_string_zeta),
                                                   :street_type => STREET_TYPE_MAP[street_type],
                                                   :name => remove_unmatchable_terms(search_string_alpha)}
    return result_matches.first if not result_matches.empty?
    # failing that, try a straight search
    result_matches = Street.search remove_unmatchable_terms(search_terms.join(' '))
    return result_matches.first if not result_matches.empty?
    # try only immediate surround terms to street_type
    result_matches = Street.search :conditions => {:settlement => remove_unmatchable_terms(search_string_zeta).split(' ').first,
                                                   :street_type => STREET_TYPE_MAP[street_type],
                                                   :name => remove_unmatchable_terms(search_string_alpha).split(' ').last}
    return result_matches.first if not result_matches.empty?
    # other wise we'll run the search based on street name, type, and the "others" and return what we find
    result_matches = Street.search remove_unmatchable_terms(search_string_zeta),
                                   :conditions => {:name => remove_unmatchable_terms(search_string_alpha),
                                                   :street_type => STREET_TYPE_MAP[street_type]},
                                                   #:match_mode => :any,
                                                   :sort_mode => :extended,
                                                   :order => "@weight DESC",
                                                   :field_weights => {:name => 10, 
                                                                      :settlement => 1,
                                                                      :street_type => 1}
    return result_matches.first if not result_matches.empty?

# other wise we'll run the search based on street name, type, and the "others" and return what we find
    result_matches = Street.search remove_unmatchable_terms(search_string_zeta),
                                   :conditions => {:name => remove_unmatchable_terms(search_string_alpha).split(' ').last,
                                                   :settlement => remove_unmatchable_terms(search_string_zeta).split(' ').first,
                                                   :street_type => STREET_TYPE_MAP[street_type]},
                                                   #:match_mode => :any,
                                                   :sort_mode => :extended,
                                                   :order => "@weight DESC",
                                                   :field_weights => {:name => 10, 
                                                                      :settlement => 1,
                                                                      :street_type => 1}
    return result_matches.first if not result_matches.empty?


    # failing that, try just to hit zeta term
    result_matches = ThinkingSphinx.search :conditions => {:name => remove_unmatchable_terms(search_string_zeta)}, :sort_mode => :extended, :order => "@weight DESC"
    return result_matches.empty? ? nil : result_matches.first
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

def get_buzz_words(terms, map)
  terms.each do |term|
    if map.include?(term)
      return term
    end
  end
  nil
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


#### Trying something different functions

def search_location2(search_string)
  puts "----------------------------------------------------------------------------"
  puts "search_string: #{search_string}"
  # latinize, remove all punctiation other than dashes, and downcase
  pure_string = search_string.purify
  puts "pure_string: #{pure_string}"
  # perform some latin morphing, split into an array, and perform some extra georgian morphing
  search_terms = pure_string.georgian_morph('extended').split(' ')
  puts "search_terms: #{search_terms.join(' ')}"

  # Get likely street type
  likely_street_type = get_likely_street_type(search_terms)

  # Get likely streets and locales
  if has_street_type?(search_terms)
    temp = split_by_street_type(search_terms)
    search_string_alpha = temp[0]
    search_string_zeta = temp[1]
    puts "-----------------"
    puts search_string_alpha
    puts search_string_zeta
    puts "-----------------"
    likely_streets = get_likely_streets(search_string_alpha.split(' '), false)
    likely_locales = get_likely_locales(search_string_zeta.split(' '))
  else
    likely_streets = get_likely_streets(search_terms, true)
    likely_locales = get_likely_locales(search_terms)
  end

  puts "______________"
  puts "likely_street_type is #{likely_street_type}"
  puts "likely_streets are #{likely_streets}"
  puts "likely_locales are #{likely_locales}"
  puts "______________"

  likely_streets_bool = booleanize(likely_streets)
  likely_locales_bool = booleanize(likely_locales)

  unless likely_streets == nil
    result_matches = Street.search likely_locales_bool,  :conditions => {:name => likely_streets_bool,
                                                         :street_type => likely_street_type},
                                                         :match_mode => :boolean,
                                                         :sort_mode => :extended,
                                                         :order => "@weight DESC"
  end

  return result_matches.first.full_name_en unless result_matches.empty?
  return "FAIL"
  return get_likely_locales(search_terms)

  #likely_number = get_likely_number(search_terms)

####
end

def get_likely_street_type(search_terms)
#search_terms = search_string.split(' ')
# If there's street type in the search terms return what type of street it refers to
if has_street_type?(search_terms)
  return STREET_TYPE_MAP[get_street_type(search_terms)] 
# Otherwise try to see if there is a likely street
elsif get_likely_streets(search_terms, true)
  return "Street"
else
  return nil
end
end

def get_likely_streets(search_terms, remove_cities = true)
# Return array of likely streets, if there are none then return nil
likely_streets = []
locale_matches = remove_cities ? match('locale', remove_unmatchable_terms(search_terms)) : []
street_matches = match('street', remove_unmatchable_terms(search_terms)).each do |s|
  flag = false
  locale_matches.each do |c|
    flag = true if s.include?(c)
  end
  likely_streets << s unless flag
end
puts "=)"
puts locale_matches
puts "=)"
return likely_streets.empty? ? nil : likely_streets
end

def get_likely_locales(search_terms)
# Return array of likely locales, if there are none then return nil
likely_locales = []
likely_locales = match('locale', remove_unmatchable_terms(search_terms))
return likely_locales.empty? ? nil : likely_locales
end    

def split_by_street_type(search_terms)
street_type = get_street_type(search_terms)
puts "street_type: #{street_type}"
# algorithm to split the terms into two strings, separated by the type
search_string_alpha = ''
search_string_zeta = ''
flag = false
search_terms.each do |term|
  if term == street_type
    flag = true
    next
  end
  search_string_alpha += "#{term} " unless flag == true
  search_string_zeta += "#{term} " if flag == true
end
ary = []
ary << search_string_alpha
ary << search_string_zeta
return ary
end






