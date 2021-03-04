class Station < ApplicationRecord
  has_many :fares
  validates :name, presence: true
  fake = ['sugamo', 'sengoku', 'shinjuku', 'sugamo', 'nakai', 'ueno']
end
