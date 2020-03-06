def find_user(user)
    system "clear"
    prompt = TTY::Prompt.new
    username = prompt.ask("Please enter the name of the user you're seeking, or enter 'exit' to leave: ")
    if username == "exit"
            return    
    else
        myuser = User.find_by(name: username)
        if myuser
            view_user(myuser, user)
        else
            prompt.select("We couldn't find this user in our database. Please try again.", ["Back"])
            find_user(user)
        end
    end
end

def view_user(myuser, user)
    system "clear"
    prompt = TTY::Prompt.new
    resp = prompt.select("#{myuser.name} Menu", ["Reviews", "Trips", "Back"])
    if resp == "Reviews"
        if myuser.reviews.length > 0
            print "Here are #{myuser.name}'s reviews:\n\n"
            myuser.reviews.each { |rev| print "Site: #{rev.site.name}\nLocation: #{rev.site.destination.name}\nRating: #{rev.rating} - #{rev.content }\n\n" }
            prompt.select("Press enter to go back", ["Back"])
            view_user(myuser, user)
        else
            puts "#{myuser.name} has no reviews... yet!"
            prompt.select("Press enter to go back", ["Back"])
            view_user(myuser, user)
        end
    elsif resp == "Trips"
        if myuser.trips.length > 0
            print "Here are #{myuser.name}'s trips:\n\n"

            myuser.trips.each { |tr|
                puts "Trip ID: #{tr.id}"
                puts "Destination: #{tr.destination.name}, #{tr.destination.country}"
                puts "Duration: #{tr.depart_date.strftime("%F")} - #{tr.return_date.strftime("%F")}"
                puts
            }
            prompt.select("Press enter to go back", ["Back"])
            view_user(myuser, user)
        else
            puts "#{myuser.name} has no trips... yet!"
            prompt.select("Press enter to go back", ["Back"])
            view_user(myuser, user)
        end
    else
        find_user(user)
    end
end