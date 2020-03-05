require_relative '../config/environment.rb'

def login
    system "clear"
    world_map
    prompt = TTY::Prompt.new
    resp = prompt.select("Welcome to the App! Please log in or create a new account.", ["Login", "Create Account", "Exit"])
    case resp
    when "Exit"
        return
    when "Login"
        username = prompt.ask("Enter your username: ")
        password = prompt.mask("Enter your password: ")
        user = User.where(username: username, password: password).first
        if user
            main_menu(user)
        else
            prompt.select("We couldn't find a user with your name. Please try again, or create a new account.", ["Back"])
        end
    when "Create Account"
        name = prompt.ask("Enter your name: ")
        user = User.create(name: name, username: make_username(name), password: "Password")
        main_menu(user)
    end
    login
end

def main_menu(user)
    system "clear"
    prompt = TTY::Prompt.new
    input = prompt.select("Main Menu", ["Add Trip", "My Trips", "My Reviews", "Find User", "Log Out", "Change Password", "Delete Account"])

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
    when "Change Password"
        change_password(user)
    when "Delete Account"
        delete_account(user)
        return
    end
    main_menu(user)
end

def make_username(name)
    name_lower = name.downcase.gsub(' ','')
    name_lower += (User.all.count { |user| user.name.downcase.gsub(' ', '') == name_lower } + 1).to_s
end

login