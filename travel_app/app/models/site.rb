class Site < ActiveRecord::Base
    belongs_to :destination
    has_many :reviews
    has_many :users, through: :review
end