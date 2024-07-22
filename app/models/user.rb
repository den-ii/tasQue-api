class User < ApplicationRecord
  has_many :errands, dependent: :destroy
  validates :firstname, presence: true
  validates :surname, presence: true
  validates :phone_no, presence: true, uniqueness: true
  # has_one_attached :avatar
 
end
