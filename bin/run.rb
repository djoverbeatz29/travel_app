require_relative '../config/environment.rb'

user = login

prompt = TTY::Prompt.new
input = prompt.select("Main Menu", ["Add Trip", "My Trips", "Find User"])

case input
when "Add Trip"
    add_trip(user)
when "My Trips"
    my_trips(user)
when "Find User"
    find_user(user)
end