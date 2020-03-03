class User < ActiveRecord::Base
    has_many :trips
    has_many :destinations, through: :trips

    def add_trip(destination, depart_date, return_date)
        Trip.create(destination: destination,
        user: self,
        depart_date: depart_date,
        return_date: return_date)
    end

    def delete_trip(trip)
        Trip.destroy(trip.id)
    end

    def visited_trips
        self.trips.where(visited?: true)
    end

    def pending_trips
        self.trips.where(visited?: false)
    end

    def visited_destinations
        self.trips.where(visited?: true).map { |trip| trip.destination }
    end

    def pending_destinations
        self.trips.where(visited?: false).map { |trip| trip.destination }
    end

    def visited_destination_names #with country
        self.visited_destinations.map { |dest| dest.name_with_country }
    end

    def pending_destination_names #with country
        self.pending_destinations.map { |dest| dest.name_with_country }
    end

end