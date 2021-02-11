class ResultStation < ApplicationRecord
  belongs_to :station
  belongs_to :meetle
  has_many :fares
end
