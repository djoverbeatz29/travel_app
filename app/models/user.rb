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

    def visited_destinations_name_and_trip_id
        self.trips.where(visited?: true).map {|trip| "#{trip.destination.name_with_country} - #{trip.id}"}
    end

    def pending_destinations_name_and_trip_id
        self.trips.where(visited?: false).map {|trip| "#{trip.destination.name_with_country} - #{trip.id}"}
    end
end