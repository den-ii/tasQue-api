class Errand < ApplicationRecord

  before_save :format_errand

  belongs_to :user
  validates :description, presence: true
  validates :amount, presence: true, numericality: true

  private
  
  def format_errand
    self.starting_point = starting_point.captialize
  end
end
