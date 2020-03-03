def my_trips(user)
    # choice of completed trips or trip wishlist
    system "clear"
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
    system "clear"
    trip_destination_names_and_ids = user.visited_destinations_name_and_trip_id
    trip_destination_names_and_ids << "Back"
    prompt = prompt_instance
    prompt.say("Completed Trips")
    user_input = prompt.select("Select a trip to view", trip_destination_names_and_ids)
    if user_input == "Back"
        return
    end
    trip_id = user_input.split(" - ")[1].to_i
    trip = user.visited_trips.find {|t| t.id == trip_id}
    trip_menu(user, trip)
    completed_trips(user)
end

# menu of user's wishlist
def wishlist(user)
    system "clear"
    trip_destination_names_and_ids = user.pending_destinations_name_and_trip_id
    trip_destination_names_and_ids << "Back"
    prompt = prompt_instance
    prompt.say("Trip Wishlist")
    user_input = prompt.select("Select a trip to view", trip_destination_names_and_ids)
    if user_input == "Back"
        return
    end
    trip_id = user_input.split(" - ")[1].to_i
    trip = user.pending_trips.find {|t| t.id == trip_id}
    trip_menu(user, trip)
    wishlist(user)
end

# trip menu: edit, delete, find other user's who have been here
def trip_menu(user, trip)
    system "clear"
    prompt = prompt_instance
    prompt.say("Destination: #{trip.destination.name_with_country}")
    prompt.say("Departure date: #{trip.depart_date.to_s.split(" ").first}")
    prompt.say("Return date: #{trip.return_date.to_s.split(" ").first}")
    trip_menu_options = remove_edit_option_for_completed_trip(trip)
    user_input = prompt.select("Select", trip_menu_options)
    case user_input
    when "Find other users who have been here"
        find_other_users(trip.destination, user)
    when "Edit"
        edit_trip(trip)
    when "Delete"
        delete_trip_confirmation(user, trip)
    when "Back"
        return
    end
    trip_menu(user, trip)
end

def remove_edit_option_for_completed_trip(trip)
    if trip.visited? == true
        ["Find other users who have been here", "Delete", "Back"]
    else
        ["Find other users who have been here", "Edit", "Delete", "Back"]
    end
end

def edit_trip(trip)
    # OPTIONS: change depart date, change return date, toggle visited status
    system "clear"
    visited_menu_option = change_visited_status_menu_option(trip)
    prompt = prompt_instance
    user_input = prompt.select("Select which date to edit", ["Departure date", "Return date", "Move to #{visited_menu_option}", "Back"])
    case user_input
    when "Departure date"
        edit_departure_date(trip)
    when "Return date"
        edit_return_date(trip)
    when "Move to #{visited_menu_option}"
        change_visited(trip)
    end
end

def change_visited_status_menu_option(trip)
    if trip.visited? == true
        "wishlist"
    else
        "completed trips"
    end
end

def edit_departure_date(trip)
    system "clear"
    new_departure_date = choose_date_departure(trip)
    trip.update(depart_date: new_departure_date)
end

def edit_return_date(trip)
    system "clear"
    new_return_date = choose_date_return(trip)
    trip.update(return_date: new_return_date)
end

def choose_date_departure(trip)
    prompt = prompt_instance
    # gets current date
    today = Time.now
    # sets minimum values to current date values
    min_month = today.month
    min_day = today.day
    min_year = today.year
    max_month = trip.return_date.month
    max_day = trip.return_date.day
    max_year = trip.return_date.year
    # asks for year, then uses minimum values if selected values are in current year or current month
    #YEAR
    if min_year == max_year
        year = min_year
    else
        year = prompt.slider("Year", min: min_year, max: max_year, step: 1, default: min_year)
    end
    #MONTH
    if year == min_year && year == max_year
        if min_month == max_month
            month = min_month
            day = prompt.slider("Day", min: min_day, max: max_day, step: 1, default: min_day)
        else
            month = prompt.slider("Month", min: min_month, max: max_month, step: 1, default: min_month)
            if month == min_month
                max_day = max_day_for_month(month, year)
                day = prompt.slider("Day", min: min_day, max: max_day, step: 1, default: min_day)
            elsif month == max_month
                day = prompt.slider("Day", min: min_day, max: max_day, step: 1, default: min_day)
            else
                max_day = max_day_for_month(month, year)
                day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
            end
        end
    elsif year == min_year
        month = prompt.slider("Month", min: min_month, max: 12, step: 1, default: min_month)
        if month == min_month
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: min_day, max: max_day, step: 1, default: min_day)
        else
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
        end
    elsif year == max_year
        month = prompt.slider("Month", min: 1, max: max_month, step: 1, default: 1)
        if month == max_month
            day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
        else
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
        end
    else
        month = prompt.slider("Month", min: 1, max: 12, step: 1, default: 1)
        max_day = max_day_for_month(month, year)
        day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
    end
    Time.new(year.to_i, month.to_i, day.to_i)
end

def choose_date_return(trip)
    prompt = prompt_instance
    min_month = trip.depart_date.month
    min_day = trip.depart_date.day
    min_year = trip.depart_date.year
    year = prompt.slider("Year", min: min_year, max: (min_year + 10), step: 1, default: min_year)
    if year == min_year
        month = prompt.slider("Month", min: min_month, max: 12, step: 1, default: min_month)
        if month == min_month
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: min_day, max: max_day, step: 1, default: min_day)
        else
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
        end
    else
        month = prompt.slider("Month", min: 1, max: 12, step: 1, default: 1)
        max_day = max_day_for_month(month, year)
        day = prompt.slider("Day", min: 1, max: max_day, step: 1, default: 1)
    end
    Time.new(year.to_i, month.to_i, day.to_i)
end

def max_day_for_month(month, year)
    if month == 2
        if year % 4 !=0 || (year % 100 == 0 && year % 400 != 0)
            28
        else
            29
        end
    elsif month == 4 || month == 6 || month == 9 || month == 11
        return 30
    else
        return 31
    end
end

def delete_trip_confirmation(user, trip)
    system "clear"
    prompt = prompt_instance
    user_input = prompt.select("Are you sure you want to delete this trip?", ["Yes", "No"])
    if user_input == "Yes"
        user.delete_trip(trip)
    end
end

def find_other_users(trip_destination, user)
    system "clear"
    prompt = prompt_instance
    other_trips = Trip.where(destination: trip_destination, visited?: true)
    other_trips_without_current_user = other_trips.reject {|trip| trip.user == user}
    other_users = other_trips_without_current_user.collect {|trip| trip.user.name}.uniq
    if other_users.empty? == true
        prompt.say("No other users have visited this destination")
    else
        other_users.each do |name|
            prompt.ok(name)
        end
    end
    prompt.select("Press Enter to go back", ["Back"])
end

def change_visited(trip)
    if trip.visited? == true
        trip.update(visited?: false)
    else
        trip.update(visited?: true)
    end
end