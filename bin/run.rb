require_relative '../config/environment.rb'

def main_menu(user)
    system "clear"
    prompt = TTY::Prompt.new
    input = prompt.select("Main Menu", ["Add Trip", "My Trips", "Find User", "Exit"])

    case input
    when "Add Trip"
        add_trip(user)
    when "My Trips"
        my_trips(user)
    when "Find User"
        find_user(user)
    when "Exit"
        return
    end
    main_menu(user)
end

user = login
main_menu(user)