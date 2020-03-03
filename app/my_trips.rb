require_relative '../config/environment.rb'

def my_trips(user)
    # choice of completed trips or trip wishlist
    user_input = select_completed_trips_or_wishlist
    if user_input == "Trip wishlist"
        wishlist(user)
    elsif user_input == "Completed trips"
        completed_trips(user)
    else
        return
    end
    my_trips(user)
end

def prompt_instance
    TTY::Prompt.new
end

def select_completed_trips_or_wishlist
    prompt = prompt_instance
    prompt.select("Select which trips to view", ["Trip wishlist", "Completed trips", "Back"])
end

# menu of user's completed trips
def completed_trips(user)
    trip_destination_names = user.visited_destination_names
    trip_destination_names << "Back"
    prompt = prompt_instance
    prompt.say("Completed Trips")
    user_input = prompt.select("Select a trip to view", trip_destination_names)
    if user_input == "Back"
        return
    end
    city_name = user_input.split(", ")[0]
    trip = user.visited_trips.find {|t| t.destination.name == city_name}
    trip_menu(user, trip)
    completed_trips(user)
end

# menu of user's wishlist
def wishlist(user)
    trip_destination_names = user.pending_destination_names
    trip_destination_names << "Back"
    prompt = prompt_instance
    prompt.say("Trip Wishlist")
    user_input = prompt.select("Select a trip to view", trip_destination_names)
    if user_input == "Back"
        return
    end
    city_name = user_input.split(", ")[0]
    trip = user.pending_trips.find {|t| t.destination.name == city_name}
    trip_menu(user, trip)
    wishlist(user)
end

# trip menu: edit, delete, find other user's who have been here
def trip_menu(user, trip)
    prompt = prompt_instance
    prompt.say("Destination: #{trip.destination.name_with_country}")
    prompt.say("Departure date: #{trip.depart_date.to_s.split(" ").first}")
    prompt.say("Return date: #{trip.return_date.to_s.split(" ").first}")
    user_input = prompt.select("Select", ["Find other users who have been here", "Edit", "Delete", "Back"])
    case user_input
    when "Find other users who have been here"
        find_other_users(trip.destination)
    when "Edit"
        edit_trip(trip)
    when "Delete"
        delete_trip_confirmation(user, trip)
    when "Back"
        return
    end
    trip_menu(user, trip)
end

def edit_trip(trip)
    # OPTIONS: change depart date, change return date, toggle visited status
    prompt = prompt_instance
    user_input = prompt.select("Select which date to edit", ["Departure date", "Return date", "Change visited status", "Back"])
    case user_input
    when "Departure date"
        edit_departure_date(trip)
    when "Return date"
        edit_return_date(trip)
    when "Change visited status"
        change_visited(trip)
    end
end

def edit_departure_date(trip)
    new_departure_date = choose_date
    trip.update(depart_date: new_departure_date)
end

def edit_return_date(trip)
    new_return_date = choose_date
    trip.update(return_date: new_return_date)
end

def choose_date
    prompt = prompt_instance
    # gets current date
    today = Time.now
    # sets minimum values to current date values
    min_month = today.month
    min_day = today.day
    min_year = today.year
    # asks for year, then uses minimum values if selected values are in current year or current month
    year = prompt.slider("Year", min: min_year, max: (min_year + 10), step: 1, default: min_year)
    if year == min_year
        month = prompt.slider("Month", min: min_month, max: 12, step: 1, default: min_month)
        if month == min_month
            max_day = max_day_for_month(month)
            day = prompt.slider("Day", min: min_day, max: max_day, step: 1, default: min_day)
        else
            max_day = max_day_for_month(month)
            day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
        end
    else
        month = prompt.slider("Month", min: 1, max: 12, step: 1, default: 1)
        max_day = max_day_for_month(month)
        day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
    end
    Time.new(year.to_i, month.to_i, day.to_i)
end

def max_day_for_month(month)
    if month == 2
        return 28
    elsif month == 4 || month == 6 || month == 9 || month == 11
        return 30
    else
        return 31
    end
end

def delete_trip_confirmation(user, trip)
    prompt = prompt_instance
    user_input = prompt.select("Are you sure you want to delete this trip?", ["Yes", "No"])
    if user_input == "Yes"
        user.delete_trip(trip)
    end
end

def find_other_users(trip_destination)
    prompt = prompt_instance
    other_trips = Trip.where(destination: trip_destination, visited?: true)
    other_users = other_trips.collect {|trip| trip.user.name}.uniq
    other_users.each do |name|
        prompt.ok(name)
    end
    prompt.select("These are the users who have traveled to this destination", ["Back"])
end

def change_visited(trip)
    if trip.visited? == true
        trip.update(visited?: false)
    else
        trip.update(visited?: true)
    end
end

jack = User.all[0]

mike = User.all[1]

# d = Destination.where(id: 751).first
# t = mike.add_trip(d, nil, nil)
# t.update(visited?: false)

my_trips(mike)