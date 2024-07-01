class User < ApplicationRecord
  validates :firstname, presence: true
  validates :surname, presence: true
  validates :phone_no, presence: true, uniqueness: true
  validates :country_code, presence: true
  validates :country, presence: true
  validates :state, presence: true
 
end
