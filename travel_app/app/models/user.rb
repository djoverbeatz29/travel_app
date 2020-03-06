class User < ActiveRecord::Base
    has_many :trips
    has_many :destinations, through: :trips
    has_many :reviews
    has_many :sites, through: :reviews

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

    def visited_trips
        self.trips.where(visited?: true)
    end

    def pending_trips
        self.trips.where(visited?: false)
    end

    def visited_destinations_name_and_trip_id
        self.trips.where(visited?: true).map {|trip| [trip.destination.name_with_country, trip.id]}
    end

    def pending_destinations_name_and_trip_id
        self.trips.where(visited?: false).map {|trip| [trip.destination.name_with_country, trip.id]}
    end

    def leave_review(site, rating, content = nil)
        review = Review.create({rating: rating,
            content: content,
            user: self,
            site: site
        })
        self.reviews << review
        review
    end

    def delete_review(review)
        review = Review.destroy(review.id)
        self.reviews.delete(review)
        review
    end
    
end