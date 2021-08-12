class Customer < ApplicationRecord
  has_many :vehicles

  validates :email, presence: true, uniqueness: true
end
