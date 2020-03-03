def login
    prompt = TTY::Prompt.new
    resp = prompt.select("Welcome to the App! Please log in or create a new account.", ["Login", "Create Account"])
    username = prompt.ask("Enter your name: ")
    user = User.find_or_create_by(name: username)
    user
end