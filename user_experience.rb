require_relative 'config/environment.rb'

# Homepage
prompt = TTY::Prompt.new
resp = prompt.select("Welcome to the App! Please log in or create a new account.",
    ["Login", "Create Account"])

username = prompt.ask("Enter your name: ")
User.find_or_create_by(name: username)

resp = prompt.select("MAIN MENU - Please select from the following options",
    ["Add Trip", "My Trips"])

if resp == "Add Trip"
    while city = prompt.ask("Enter the name of the city you wish to visit")
        if Destination.find_by(name: city)
            break
        else
            puts "Invalid response."
        end
    end

    while arrive = prompt.ask("Enter the date you wish to arrive, in MM-DD-YYYY format: ")
        if 
            break
        else
            puts "Invalid response."
        end
    end

    while leave = prompt.ask("Enter the date you wish to return, also in MM-DD-YYYY format: ")
        if 
            break
        else
            puts "Invalid response."
        end
    end

    Trip.create({})
end