class Meetle < ApplicationRecord
  belongs_to :user
  has_many :locations
  has_many :result_stations
  has_many :stations, through: :locations
end
