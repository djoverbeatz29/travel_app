require_relative '../config/environment.rb'

def login
    system "clear"
    prompt = TTY::Prompt.new
    resp = prompt.select("Welcome to the App! Please log in or create a new account.", ["Login", "Create Account", "Exit"])
    if resp == "Exit"
        return
    else
        username = prompt.ask("Enter your name: ")
        user = User.find_or_create_by(name: username)
        main_menu(user)
    end
    login
end

def main_menu(user)
    system "clear"
    prompt = TTY::Prompt.new
    input = prompt.select("Main Menu", ["Add Trip", "My Trips", "My Reviews", "Find User", "Log Out"])

    case input
    when "Add Trip"
        add_trip(user)
    when "My Trips"
        my_trips(user)
    when "My Reviews"
        my_reviews(user)
    when "Find User"
        find_user(user)
    when "Log Out"
        return
    end
    main_menu(user)
end

login