def login
    system "clear"
    prompt = TTY::Prompt.new
    resp = prompt.select("Welcome to the App! Please log in or create a new account.", ["Login", "Create Account", "Exit"])
    if resp == "Exit"
        return
    else
        username = prompt.ask("Enter your name: ")
        user = User.find_or_create_by(name: username)
        user
    end
end