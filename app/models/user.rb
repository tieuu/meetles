class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable
  has_many :locations
  has_many :stations, through: :locations
  has_many :meetles, through: :locations
  # has_many :meetles_as_owner, class_name: "Meetle", foreign_key: :user_id

  validates :email, presence: true
  validates :password, presence: true

  acts_as_favoritor
end
