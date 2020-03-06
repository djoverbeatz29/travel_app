def add_trip(user)
    system "clear"
    @now = Time.now

    prompt = TTY::Prompt.new
    resp = prompt.select("Search by city or country, or click Exit to return to Main Menu", ["By City", "By Country", "Exit"])
    if resp == "By City"
        system "clear"
        while resp = prompt.ask("Enter the name of the city you wish to visit, or type 'cancel' to go back: ")
            if resp == 'cancel'
                break
            else
                matches = Destination.where(name: resp)
                if matches.length == 0
                    puts "Invalid response."
                elsif matches.length == 1
                    destination = matches[0]
                    break
                else
                    resp = prompt.select("We found multiple matches for #{resp}. Select from the following list:", matches.map { |m| ["#{m.name}, #{m.subcountry}, #{m.country}", m.id] }.to_h, per_page: 10)
                    destination = Destination.find(resp)
                    break
                end
            end
        end

    elsif resp == "By Country"
        system "clear"
        nations = Destination.all.map { |d| d.country }.uniq
        char = prompt.select("Please select the first letter of the country you seek.", (65...65+26).map { |i| i.chr })
        system "clear"
        nat = prompt.select("Choose your country.", nations.find_all { |n| n[0] == char }, per_page: 10)
        sub = prompt.select("Now choose your subcountry.", Destination.where(country: nat).map{ |c| c.subcountry }.uniq, per_page: 10)
        city = prompt.select("Finally, choose your city.", Destination.where(country: nat, subcountry: sub).map{ |c| c.name }.uniq, per_page: 10)
        destination = Destination.find_by(name: city, subcountry: sub, country: nat)
    else
        return
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
    puts "Great! You'll be heading to #{destination.name} on #{depart_date.strftime("%F")} and returning on #{return_date.strftime("%F")}."
    puts "Your confirmation email should be arriving shortly at #{user.username}@gmail.com.\n"
    resp = prompt.select("Options", ["Add another trip", "Exit"])
    if resp == "Add another trip"
        add_trip(user)
    else
        return
    end

end

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