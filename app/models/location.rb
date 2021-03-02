class Location < ApplicationRecord
  self.primary_key = 'meetle_id'
  belongs_to :user
  belongs_to :meetle
  belongs_to :station
  validates :meetle, :station, presence: true
end
