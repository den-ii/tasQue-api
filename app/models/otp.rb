class Otp < ApplicationRecord
  validates :phone_no, uniqueness: true
end
