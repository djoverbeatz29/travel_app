class Destination < ActiveRecord::Base
    has_many :trips
    has_many :users, through: :trips
    has_many :sites

    def name_with_country
        "#{self.name}, #{self.country}"
    end

    def add_site(site_name)
        Site.create(name: site_name, destination: self)
    end

end