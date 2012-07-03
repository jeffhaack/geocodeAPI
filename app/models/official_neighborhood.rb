class OfficialNeighborhood < ActiveRecord::Base
  has_many :addresses, :dependent => :nullify
	has_many :streets, :dependent => :nullify
	belongs_to :city_district
	belongs_to :settlement
	belongs_to :district
	belongs_to :region

	define_index do
  	  indexes name_en, :as => :name
      set_property :morphology => 'metaphone'
#  	  indexes city_district.name_en, :as => :city_district
#  	  indexes settlement.name_en, :as => :settlement
#  	  indexes district.name_en, :as => :district
#  	  indexes region.name_en, :as => :region
  	end
end
