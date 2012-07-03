class Street < ActiveRecord::Base
	belongs_to :official_neighborhood
	belongs_to :city_district
	belongs_to :settlement
	belongs_to :district
	belongs_to :region
	has_many :addresses, :dependent => :nullify

	define_index do
  	  indexes full_name_en, :as => :name
      set_property :morphology => 'metaphone'
#  	  indexes street_type_en, :as => :street_type
#  	  indexes official_neighborhood.name_en, :as => :neighborhood
#  	  indexes city_district.name_en, :as => :city_district
#  	  indexes settlement.name_en, :as => :settlement
#  	  indexes district.name_en, :as => :district
#  	  indexes region.name_en, :as => :region
  	end
end
