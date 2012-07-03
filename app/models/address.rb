class Address < ActiveRecord::Base
  belongs_to :official_neighborhood
  belongs_to :city_district
  belongs_to :settlement
  belongs_to :district
  belongs_to :region
  belongs_to :street


end
