def find_user(user)

    prompt = TTY::Prompt.new
    while username = prompt.ask("Please enter the name of the user you're seeking, or enter 'exit' to leave: ")
        if username == "exit"
            return    
        else
            myuser = User.find_by(name: username)
            if myuser
                resp = prompt.select("#{myuser.name} Menu", ["Reviews", "Trips", "Back"])
                if resp == "Reviews"
                    if myuser.reviews.length > 0
                        print "Here are #{username}'s reviews:\n\n"
                        myuser.reviews.each { |rev| print "Site: #{rev.site.name}\nRating: #{rev.rating} - #{rev.content }\n\n" }
                    else
                        puts "#{username} has no reviews... yet!"
                    end
                elsif resp == "Trips"
                    if myuser.trips.length > 0
                        print "Here are #{username}'s trips:\n\n"

                        myuser.trips.each { |tr|
                            puts "Trip ID: #{tr.id}"
                            puts "Destination: #{tr.destination.name}, #{tr.destination.country}"
                            puts "Duration: #{tr.depart_date.strftime("%F")} - #{tr.return_date.strftime("%F")}"
                            puts
                        }
                    else
                        puts "#{username} has no trips... yet!"
                    end
                else
                    find_user(user)
                end
            else
                puts "We couldn't find this user in our database. Please try again."
            end
        end
    end
    resp = prompt.select("Options", ["Back", "Exit"])
    if resp == "Back"
        find_user(user)
    else
        return
    end
end