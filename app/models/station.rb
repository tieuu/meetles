class Station < ApplicationRecord
  has_many :fares

  validates :name, presence: true
  geocoded_by :name_kanji
  fake = ['sugamo', 'sengoku', 'shinjuku']
  fake << ['sugamo', 'nakai', 'akebonobashi']
  after_validation :geocode, if: ->(obj){ fake.include?(obj.name) }

end
