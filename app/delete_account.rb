def delete_account(user)
    system "clear"
    prompt = TTY::Prompt.new
    resp = prompt.select("Are you sure?", ["Yes", "No"])
    case resp
    when "Yes"
        Trip.where(user_id: user.id).each { |t| t.destroy }
        Review.where(user_id: user.id).each { |r| r.destroy }
        user.destroy
        prompt.select("Your account has been successfully deleted. We hope to see you again someday.\nAu revoir!", ["Back"])
    end
    return
end