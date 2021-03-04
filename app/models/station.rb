class Station < ApplicationRecord
  has_many :fares

  validates :name, presence: true
  geocoded_by :name_kanji
  fake = ['sugamo', 'sengoku', 'shinjuku' , 'sugamo', 'nakai', 'ueno']
  after_validation :geocode, if: ->(obj){ fake.include?(obj.name) }
end
