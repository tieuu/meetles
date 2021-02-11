class Meetle < ApplicationRecord
  belongs_to :user
  has_many :locations
  has_many :result_stations
end
