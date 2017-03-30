class Product < ApplicationRecord
  # ... edited by app gen (product resource)
  default_scope { order :name }

  belongs_to :user
end
