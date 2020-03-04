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
    trip_destination_names_and_ids_arr = user.visited_destinations_name_and_trip_id
    trip_destination_names = convert_array_of_arrays_to_hash(trip_destination_names_and_ids_arr)
    trip_destination_names["Back"] = "Back"
    prompt = prompt_instance
    prompt.say("Completed Trips")
    trip_id = prompt.select("Select a trip to view", trip_destination_names)
    if trip_id == "Back"
        return
    end
    trip = user.visited_trips.find {|t| t.id == trip_id}
    trip_menu(user, trip)
    completed_trips(user)
end

# menu of user's wishlist
def wishlist(user)
    system "clear"
    trip_destination_names_and_ids_arr = user.pending_destinations_name_and_trip_id
    trip_destination_names = convert_array_of_arrays_to_hash(trip_destination_names_and_ids_arr)
    trip_destination_names["Back"] = "Back"
    prompt = prompt_instance
    prompt.say("Trip Wishlist")
    trip_id = prompt.select("Select a trip to view", trip_destination_names)
    if trip_id == "Back"
        return
    end
    trip = user.pending_trips.find {|t| t.id == trip_id}
    trip_menu(user, trip)
    wishlist(user)
end

def convert_array_of_arrays_to_hash(a_of_a)
    hash = {}
    a_of_a.each {|arr| hash[arr[0]] = arr[1]}
    hash
end

# trip menu: edit, delete, find other user's who have been here
def trip_menu(user, trip)
    system "clear"
    prompt = prompt_instance
    prompt.say("Destination: #{trip.destination.name_with_country}")
    prompt.say("Departure date: #{trip.depart_date.to_s.split(" ").first}")
    prompt.say("Return date: #{trip.return_date.to_s.split(" ").first}")
    trip_menu_options = determine_menu_options(trip)
    user_input = prompt.select("Select", trip_menu_options)
    case user_input
    when "Find other users who have been here"
        find_other_users(trip.destination, user)
    when "Review an existing site"
        browse_sites(user, trip)
    when "Add site for this destination"
        add_site(user, trip.destination)
    when "Browse sites and reviews"
        browse_sites(user, trip)
    when "Edit"
        edit_trip(trip)
    when "Delete"
        delete_trip_confirmation(user, trip)
    when "Back"
        return
    end
    trip_menu(user, trip)
end

def determine_menu_options(trip)
    if trip.visited? == true
        ["Find other users who have been here", "Review an existing site", "Add site for this destination", "Delete", "Back"]
    else
        ["Find other users who have been here", "Browse sites and reviews", "Edit", "Delete", "Back"]
    end
end

def add_site(user, destination)
    prompt = prompt_instance
    site_name = prompt.ask("What is the name of the site?")
    new_site = Site.create(name: site_name, destination: destination)
    user_input = prompt.select("Would you like to add a review for this site?", ["Yes", "No"])
    if user_input == "Yes"
        add_site_review(user, new_site)
    end
end

def browse_sites(user, trip)
    destination_sites = Site.where(destination: trip.destination)
    site_names = destination_sites.map{|site| site.name}
    site_names << "Back"
    browse_site_prompt = determine_browse_site_prompt(trip)
    prompt = prompt_instance
    user_input = prompt.select(browse_site_prompt, site_names)
    if user_input == "Back"
        return
    end
    selected_site = Site.find_by(name: user_input)
    if trip.visited? == true
        add_site_review(user, selected_site)
    else
        view_site_reviews(selected_site)
    end
    browse_sites(user, trip)
end

def determine_browse_site_prompt(trip)
    if trip.visited? == true
        "Select a site to add a review"
    else
        "Select a site to see reviews"
    end
end

def add_site_review(user, selected_site)
    prompt = prompt_instance
    rating = prompt.slider("Rating", max: 10, step: 1)
    user_input = prompt.select("Would you like to leave a comment?", ["Yes", "No"])
    if user_input == "Yes"
        comment = prompt.ask("Enter your comment")
        user.leave_review(selected_site, rating, comment)
    else
        user.leave_review(selected_site, rating)
    end
end

def view_site_reviews(selected_site)
    prompt = prompt_instance
    selected_site.reviews.each do |review|
        prompt.say("User: #{review.user.name}")
        prompt.say("Rating: #{review.rating}")
        if review.content
            prompt.say("Review: #{review.content}")
        end
        prompt.say("\n")
    end
    prompt.select("Press Enter to go back to list of sites", ["Back"])
end

def edit_trip(trip)
    # OPTIONS: change depart date, change return date, toggle visited status
    system "clear"
    prompt = prompt_instance
    user_input = prompt.select("Select which date to edit", ["Departure date", "Return date", "Move to completed trips", "Back"])
    case user_input
    when "Departure date"
        edit_departure_date(trip)
    when "Return date"
        edit_return_date(trip)
    when "Move to completed trips"
        change_visited(trip)
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
            day = prompt.slider("Day", min: min_day, max: max_day, step: 1)
        else
            month = prompt.slider("Month", min: min_month, max: max_month, step: 1)
            if month == min_month
                max_day = max_day_for_month(month, year)
                day = prompt.slider("Day", min: min_day, max: max_day, step: 1)
            elsif month == max_month
                day = prompt.slider("Day", min: min_day, max: max_day, step: 1)
            else
                max_day = max_day_for_month(month, year)
                day = prompt.slider("Day", min: 1, max: max_day, step: 1)
            end
        end
    elsif year == min_year
        month = prompt.slider("Month", min: min_month, max: 12, step: 1)
        if month == min_month
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: min_day, max: max_day, step: 1)
        else
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: 1, max: max_day, step: 1)
        end
    elsif year == max_year
        month = prompt.slider("Month", min: 1, max: max_month, step: 1)
        if month == max_month
            day = prompt.slider("Day", min: 1, max: max_day, step: 1)
        else
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: 1, max: max_day, step: 1)
        end
    else
        month = prompt.slider("Month", min: 1, max: 12, step: 1)
        max_day = max_day_for_month(month, year)
        day = prompt.slider("Day", min: 1, max: max_day, step: 1)
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
        month = prompt.slider("Month", min: min_month, max: 12, step: 1)
        if month == min_month
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: min_day, max: max_day, step: 1)
        else
            max_day = max_day_for_month(month, year)
            day = prompt.slider("Day", min: 1, max: max_day, step: 1)
        end
    else
        month = prompt.slider("Month", min: 1, max: 12, step: 1)
        max_day = max_day_for_month(month, year)
        day = prompt.slider("Day", min: 1, max: max_day, step: 1)
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
    elsif [4, 6, 9, 11].include?(month) == true
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
    other_users_arr = other_trips_without_current_user.collect {|trip| [trip.user.name, trip.user.id]}.uniq
    if other_users_arr.empty? == true
        prompt.select("No other users have visited this destination", ["Back"])
    else
        user_with_id_hash = convert_array_of_arrays_to_hash(other_users_arr)
        user_with_id_hash["Back"] = "Back"
        selected_user_id = prompt.select("Select a user to see their reviews", user_with_id_hash)
        if selected_user_id == "Back"
            return
        end
        see_user_reviews(trip_destination, selected_user_id)
        find_other_users(trip_destination, user)
    end
end

def see_user_reviews(trip_destination, selected_user_id)
    # Site Name
    # Rating
    # Content
    prompt = prompt_instance
    user = User.find(selected_user_id)
    reviews = user.reviews.select {|review| review.site.destination == trip_destination}
    if reviews.empty? == true
        prompt.say("This user has not reviewed any sites for this destination")
    else
        reviews.each do |rev|
            prompt.say("Site: #{rev.site.name}")
            prompt.say("Rating: #{rev.rating}")
            if rev.content
                prompt.say("Content: #{rev.content}")
            end
            prompt.say("\n")
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