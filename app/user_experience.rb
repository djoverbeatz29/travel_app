require_relative 'config/environment.rb'

# Homepage
@now = Time.now
def month_max(mo, year = Time.now.year)
    if mo == 2
        if year % 4 !=0 || (year % 100 == 0 && year % 400 != 0)
            28
        else
            29
        end
    elsif [4, 6, 9, 11].include?(mo)
        30
    else
        31
    end
end

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

    puts "Enter the date you wish to arrive."
    year = prompt.slider('Year', min: 2020, max: 2025)
    month = prompt.slider('Month', min: year == @now.year ? @now.month : 1, max: 12)
    day = prompt.slider('Day', min: month == @now.month ? @now.day : 1, max: month_max(month, year))
    depart_date = Time.new(year, month, day)

    puts "Enter the date you wish to return."
    year = prompt.slider('Year', min: depart_date.year, max: depart_date.year + 1)
    month = prompt.slider('Month', min: year == depart_date.year ? depart_date.month : 1, max: 12)
    day = prompt.slider('Day', min: month == depart_date.month ? depart_date.day : 1, max: month_max(month, year))
    return_date = Time.new(year, month, day)

    user.add_trip(destination, depart_date, return_date)

elsif resp == "Find User"
    while username = prompt.ask("Please enter the name of the user you're seeking: ")
        myuser = User.find_by(name: username)
        if myuser
            if myuser.trips.length > 0
                print "Here are #{username}'s trips:\n\n"

                myuser.trips.each { |tr|
                    puts "Trip ID: #{tr.id}"
                    puts "Destination: #{tr.destination.name}"
                    puts "Duration: #{tr.depart_date.to_s.split(' ')[0]} - #{tr.return_date.to_s.split(' ')[0]}"
                    puts
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