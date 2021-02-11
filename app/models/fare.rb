class Fare < ApplicationRecord
  belongs_to :result_station
  belongs_to :station
end
