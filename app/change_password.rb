def change_password(user)
    # system "clear"
    prompt = TTY::Prompt.new
    while resp = prompt.mask("Please enter your current password, or enter 'exit' to give up.")
        case resp
        when user.password
            puts "Correct!"
            while new_password = prompt.mask("Please enter your new password, or enter 'cancel' to go back to Main Menu.")
                if new_password == 'cancel'
                    return
                else
                    resp = prompt.mask("Thanks! Now enter it again.")
                    case resp
                    when new_password
                        user.update(password: new_password)
                        prompt.select("You have successfully changed your password.", ["Back"])
                        return
                    else
                        puts "Incorrect. Try again"
                    end
                end
            end 
        when 'exit'
            return
        else
            puts "Incorrect. Try again."
        end
    end
    return
end