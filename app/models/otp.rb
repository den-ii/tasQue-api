class Otp < ApplicationRecord
  validates :phone_no, presence: true
end
