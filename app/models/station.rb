class Station < ApplicationRecord
  has_many :fares

  validates :name, presence: true
end
