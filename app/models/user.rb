class User < ActiveRecord::Base
    has_many :trips
    has_many :destinations, through: :trips

    def add_trip(destination, depart_date, return_date, visited = false)
        Trip.create(destination: destination,
        user: self,
        depart_date: depart_date,
        return_date: return_date,
        visited?: visited)
    end

    def delete_trip(trip)
        Trip.destroy(trip.id)
    end

    def visited_destinations
        self.trips.where(visited?: true).map { |trip| trip.destination }
    end

    def pending_destinations
        self.trips.where(visited?: false).map { |trip| trip.destination }
    end

end