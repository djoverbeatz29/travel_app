class Destination < ActiveRecord::Base
    has_many :trips
    has_many :users, through: :trips

    def name_with_country
        "#{self.name}, #{self.country}"
    end
end