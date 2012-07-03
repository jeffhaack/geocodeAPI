class Settlement < ActiveRecord::Base
  has_many :addresses, :dependent => :nullify
  has_many :streets, :dependent => :nullify
  has_many :official_neighborhoods, :dependent => :nullify
  has_many :city_districts, :dependent => :nullify
	belongs_to :district
	belongs_to :region

  define_index do 
    indexes name_en, :as => :name
    set_property :morphology => 'metaphone'
  end
  
#	define_index 'model_literal' do
#  	  indexes name_en, :as => :name
#  	  indexes district.name_en, :as => :district
#  	  indexes region.name_en, :as => :region
#  end

#  define_index 'model_soundex' do
#      indexes name_en, :as => :name
#      #indexes district.name_en, :as => :district
#      #indexes region.name_en, :as => :region
#      set_property :morphology => 'soundex'
#  end

#  define_index 'model_metaphone' do
#      indexes name_en, :as => :name
#      indexes district.name_en, :as => :district
#      indexes region.name_en, :as => :region
#      set_property :morphology => 'metaphone'
#  end

#  define_index 'model_infix' do
#      indexes name_en, :as => :name
#      indexes district.name_en, :as => :district
#      indexes region.name_en, :as => :region
#      set_property :min_infix_len => '5'
#  end

#  define_index 'model_super' do
#      indexes district.name_en, :as => :district
#      indexes region.name_en, :as => :region
#    end

end
