class User < ApplicationRecord
  has_many :credentials, dependent: :destroy
  self.primary_key = :id
end
