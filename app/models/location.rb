class Location < ApplicationRecord
  belongs_to :user
  belongs_to :meetle
  belongs_to :station
  validates :meetle, :station, presence: true
end
