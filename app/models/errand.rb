class Errand < ApplicationRecord
  belongs_to :user
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
end
