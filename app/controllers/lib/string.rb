# -*- coding: utf-8 -*-
# Add additional Georgian language functionality to String class

####################################
#### Additional instance methods ###
####################################
# def purify(dash = true)
# def latinize(map = LANG_MAP_TO_GEO)
# def georgianize(map = LANG_MAP_TO_ENG)
# def get_language
# def georgian_morph(type = 'basic')

class String

  # Set whether you want output in the terminal (for development)
  Output = false

  # Latinizes, Downcases, and clears non word characters; by default leaves dashes
  def purify(dash = true)
    new_string = self.latinize.downcase.strip
    new_string.gsub!('-','9lbdotspace9') if dash
    new_string.gsub!(/\W+/,' ')
    new_string.gsub!('9lbdotspace9', '-') if dash
    if Output
      puts "------------------------------------------------------------------------------"
      puts "String::purify"
      puts "String '#{self}' has been purified to #{new_string}"
      puts "------------------------------------------------------------------------------"
    end
    new_string
  end

  # Converts Georgian script to latin;
  # doing this for all strings because the morphology in sphinx works well in English
  def latinize(map = LANG_MAP_TO_GEO)
    new_string = String.new(self)
    map.each do |latin, georgian|
      georgian.each do |ge|
        new_string.gsub!(ge,latin)
      end
    end
    if Output
      puts "------------------------------------------------------------------------------"
      puts "String::latinize"
      puts "String '#{self}' has been latinized to #{new_string}"
      puts "------------------------------------------------------------------------------"
    end
    new_string
  end

  # Converts Latin script to Georgian - uses keyboard syntax, so T => თ and t => ტ
  def georgianize(map = LANG_MAP_TO_ENG)
    new_string = String.new(self)
    map.each do |latin, georgian|
        new_string.gsub!(latin,georgian)
    end
    if Output
      puts "------------------------------------------------------------------------------"
      puts "String::georgianize"
      puts "String '#{self}' has been georgianized to #{new_string}"
      puts "------------------------------------------------------------------------------"
    end
    new_string
  end

  # Returns the language of the string, either Georgian or English
	def get_language
  	ka_letters = self.count("ა-ჰ")
  	en_letters = self.count("a-zA-Z")
    if Output
      puts "------------------------------------------------------------------------------"
      puts "String::get_language"
      puts "String '#{self}' has #{en_letters} english and #{ka_letters} georgian letters"
      puts "------------------------------------------------------------------------------"
    end
  	return en_letters >= ka_letters ? 'en' : 'ka'
	end

  def is_roman_numeral?
    rom_num_letters = ['i','x','v']
    str = self.downcase
    for i in 0..str.length-1
      unless rom_num_letters.include?(str[i])
        return false
      end
    end
    true
  end


  # Returns a string that has been simplified by Georgian language morphology rules
  #  if set to 'basic' (default) will convert common characters to their common format
  #  if set to 'extended' will also convert common word morphs to their unmorphed form
  #  ex. 'ceretlis qucha' in basic mode will output 'tseretlis qucha'
  #                       in extended mode will output 'tsereteli qucha'
  def georgian_morph(type = 'basic')
    new_string_terms = String.new(self).split(' ')
    if type == 'basic' or type == 'extended'
      new_string_terms.each do |term|
        for i in 0..term.length-1
          if term[i] == 'c' && term[i+1] != nil && term[i+1] != 'h'
            term[i] = 'ts'
          end
          if term[i] == 'f'
            term[i] = 'p'
          end
          if term[i] == 'p' && term[i+1] != nil && term[i+1] == 'h'
            term[i..i+1] = 'p'
          end
          if term[i] == 'x'
            term[i] = 'kh'
          end
        end
      end
    end
    if type == 'extended'
      new_string_terms.each do |term|
        term.gsub!('eblis','ebeli') if term.include?('eblis')
        term.gsub!('etlis','eteli') if term.include?('etlis')
        term.gsub!('dzis','dze') if term.include?('dzis')
        term[term.length-1] = '' if term[term.length-1] == 's' # remove any 's' from the end of a term
      end
    end
    if Output
      puts "------------------------------------------------------------------------------"
      puts "String::georgian_morph"
      puts "String '#{self}' has been morphed to #{new_string_terms.join(' ')}"
      puts "------------------------------------------------------------------------------"
    end
    return new_string_terms.join(' ')
  end


  # CONSTANTS #
  LANG_MAP_TO_GEO = { 'a'   => ['ა'],
                      'b'   => ['ბ'],
                      'g'   => ['გ'],
                      'd'   => ['დ'],
                      'e'   => ['ე'],
                      'v'   => ['ვ'],
                      'z'   => ['ზ'],
                      'i'   => ['ი'],
                      'l'   => ['ლ'],
                      'm'   => ['მ'],
                      'n'   => ['ნ'],
                      'o'   => ['ო'],
                      'zh'  => ['ჟ'],
                      'r'   => ['რ'],
                      's'   => ['ს'],
                      't'   => ['ტ','თ'],
                      'u'   => ['უ'],
                      'p'   => ['პ','ფ'],
                      'k'   => ['კ','ყ'],
                      'gh'  => ['ღ'],
                      'q'   => ['ქ'],
                      'sh'  => ['შ'],
                      'dz'  => ['ძ'],
                      'ts'  => ['ც','წ'],
                      'ch'  => ['ჩ','ჭ'],
                      'kh'  => ['ხ'],
                      'j'   => ['ჯ'],
                      'h'   => ['ჰ']  }

  LANG_MAP_TO_ENG = { 'tch' => 'ჭ',
                      'th'  => 'ტ',
                      'gh'  => 'ღ',
                      'zh'  => 'ჟ',
                      'sh'  => 'შ',
                      'dz'  => 'ძ',
                      'ts'  => 'ც',
                      'tz'  => 'წ',
                      'ch'  => 'ჩ',
                      'kh'  => 'ხ',
                      'W'   => 'ჭ',
                      't'   => 'ტ',
                      'T'   => 'თ',
                      'R'   => 'ღ',
                      'J'   => 'ჟ',
                      'S'   => 'შ',
                      'Z'   => 'ძ',
                      'c'   => 'ც',
                      'w'   => 'წ',
                      'C'   => 'ჩ',
                      'x'   => 'ხ',
                      'y'   => 'ყ',
                      'a'   => 'ა',
                      'b'   => 'ბ',
                      'g'   => 'გ',
                      'd'   => 'დ',
                      'e'   => 'ე',
                      'v'   => 'ვ',
                      'z'   => 'ზ',
                      'i'   => 'ი',
                      'l'   => 'ლ',
                      'm'   => 'მ',
                      'n'   => 'ნ',
                      'o'   => 'ო',
                      'r'   => 'რ',
                      's'   => 'ს',
                      'u'   => 'უ',
                      'p'   => 'პ',
                      'f'   => 'ფ',
                      'k'   => 'კ',
                      'q'   => 'ქ',
                      'j'   => 'ჯ',
                      'h'   => 'ჰ' }

end

  # by Paul Battley
  # measures the "distance" or difference between two strings, ie transpositions and stuff
  def levenshtein(str1, str2)
    str1 = str1.downcase
    str2 = str2.downcase

    s = str1.unpack('U*')
    t = str2.unpack('U*')
    n = s.length
    m = t.length
    return m if (0 == n)
    return n if (0 == m)
    
    d = (0..m).to_a
    x = nil

    (0...n).each do |i|
        e = i+1
        (0...m).each do |j|
            cost = (s[i] == t[j]) ? 0 : 1
            x = [
                d[j+1] + 1, # insertion
                e + 1,      # deletion
                d[j] + cost # substitution
            ].min
            d[j] = e
            e = x
        end
        d[m] = x
    end
    return x
  end