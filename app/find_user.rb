def find_user(user)

    prompt = TTY::Prompt.new
    while username = prompt.ask("Please enter the name of the user you're seeking, or enter 'exit' to leave: ")
        if username == "exit"
            return    
        else
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
    resp = prompt.select("Options", ["Back", "Exit"])
    if resp == "Back"
        find_user(user)
    else
        return
    end
end