class Meetle < ApplicationRecord
  ACTIVITY = %w[coffee food drinks fun]
  validates :activity, presence: true, inclusion: { in: ACTIVITY }
  belongs_to :user
  has_many :locations
  has_many :result_stations
  has_many :stations, through: :locations
end
