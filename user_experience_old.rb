require_relative 'config/environment.rb'

# Homepage
prompt = TTY::Prompt.new
resp = prompt.select("Welcome to the App! Please log in or create a new account.",
    ["Login", "Create Account"])

username = prompt.ask("Enter your name: ")
user = User.find_or_create_by(name: username)

resp = prompt.select("MAIN MENU - Please select from the following options:",
    ["Add Trip", "My Trips", "Find User"])

if resp == "Add Trip"
    resp = prompt.select("MAIN MENU - Search by city or country", ["By City", "By Country"])
    if resp == "By City"
        while resp = prompt.ask("Enter the name of the city you wish to visit: ")
            if Destination.find_by(name: resp)
                destination = Destination.find_by(name: resp)
                break
            else
                puts "Invalid response."
            end
        end

    else
        nations = Destination.all.map { |d| d.country }.uniq
        char = prompt.select("Please select the first letter of the country you seek.", (65...65+26).map { |i| i.chr })
        nat = prompt.select("Choose your country.", nations.find_all { |n| n[0] == char })
        sub = prompt.select("Now choose your subcountry.", Destination.where(country: nat).map{ |c| c.subcountry }.uniq)
        city = prompt.select("Finally, choose your city.", Destination.where(country: nat, subcountry: sub).map{ |c| c.name }.uniq)
        destination = Destination.find_by(name: city)
    end

    while resp = prompt.ask("Enter the date you wish to arrive, in MM-DD-YYYY format: ")
        if resp.match(/^\d{1,2}[\-\/]\d{1,2}[\-\/]\d{4}$/)
            resp = resp.split(/[\-\/]/).map { |i| i.to_i }
            depart_date = Time.new(resp[2], resp[0], resp[1])
            break
        else
            puts "Invalid response."
        end
    end

    while resp = prompt.ask("Enter the date you wish to return, also in MM-DD-YYYY format: ")
        if resp.match(/^\d{1,2}[\-\/]\d{1,2}[\-\/]\d{4}$/)
            resp = resp.split(/[\-\/]/).map { |i| i.to_i }
            return_date = Time.new(resp[2], resp[0], resp[1])
            break
        else
            puts "Invalid response."
        end
    end
    user.add_trip(destination, depart_date, return_date)

elsif resp == "Find User"
    while username = prompt.ask("Please enter the name of the user you're seeking: ")
        myuser = User.find_by(name: username)
        if myuser
            if myuser.trips.length > 0
                puts "Here are #{username}'s trips:"
                myuser.trips.each { |tr|
                    puts
                    puts "Trip ID: #{tr.id}"
                    puts "Destination: #{tr.destination.name}"
                    puts "Duration: #{tr.depart_date.to_s.split(' ')[0]} - #{tr.return_date.to_s.split(' ')[0]}"
                }
            else
                puts "#{username} has no trips... yet!"
            end
            break
        else
            puts "We couldn't find this user in our database. Please try again."
        end
    end
    
end