class District < ActiveRecord::Base
  has_many :addresses, :dependent => :nullify
	has_many :streets, :dependent => :nullify
	has_many :official_neighborhoods, :dependent => :nullify
	has_many :city_districts, :dependent => :nullify
	has_many :cities, :dependent => :nullify
	has_many :settlements, :dependent => :nullify
	belongs_to :region

	define_index do
  	  indexes name_en, :as => :name
#  	  indexes region.name_en, :as => :region
      set_property :morphology => 'metaphone'
  	end
end
