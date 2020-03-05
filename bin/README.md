README... or don't... we're fine either way!

# Jack and Mike's Travel App

We have created a command line interface (or CLI, pronounced 'clee') app whereby users can 'book' trips to over 20K cities across the world.
They can view past trips, edit future trips and visit and review tourist sites within the destinations they've visited.
Heck, they can even look at the trips and reviews of other users on the sites, by looking them up by name!

## Overview

Our app contains five tables, initialized and linked via ActiveRecord, with the following relations:

1. Users: has many sites, has many trips and has many reviews
2. Destinations: has many sites, has many trips via users
3. Sites: belongs to destinations, has many reviews
4. Trips: belongs to destinations
5. Reviews: belongs to site, belongs to user

We're following the classic CRUD format (not to be confused with POOP (https://www.youtube.com/watch?v=ww9sLVLS3Ko)):

- Create: Users can create profiles for themselves, or sites to add to the destinations they've visited, as well as reviews of said sites
- Read: Users can see their own profile information, as well as that of other users. It's like a social network, minus the memes, political discussions and lewd Inbox messages.
- Update: Users can change their passwords and their trip itineraries (departure and return dates), and they can edit their reviews (both scores and ratings)
- Destroy: Users can delete trips, reviews... and even their own accounts!

## Log In

The first page contains three options:
1. Log In - The user is prompted to enter username and password (detailed below).
    - If there is a User record with said username and password, the user is logged in and reaches the Main Menu.
    - If not, a denial message appears, and user is redirected to the Log In page.
2. Create Account - user enters their name and is assigned a default username and password (which are printed to the screen) and is then logged into their account
    - The username is a lowercase concatenation of the user's name, with a number appended (the count of users in the database with the same lowercase name string... plus one); cannot be changed
    - The default password is "Password"; this can be changed
3. Exit - this halts the script and returns user to terminal

## Main Menu

Upon logging in, the user is brought to a Main Menu with the following options:

- Add Trip
    - User can select either the city, or the country, which trickles down to country --> subcountry (e.g. states) --> city
    - They will choose a departure date, which must take place between the current date and 5 years henceforth
    - The return date must take place between the departure date and one year henceforth
- My Trips
    - This produces a list of trips, bifurcated into "Wishlist" (trips not so far taken) and "Completed" (trips already taken)
    - Trips can be manually edited: by departure date, return date and whether completed or not
    - In addition, trips can be deleted
- My Reviews
    - This produces a list of reviews made by the users
- Find User
    - Logged-in users can search other users by name; if there is a match, the user can view the other user's trips and reviews
- Change Password
    - Passwords default to "Password", but they can be edited any number of times, via a 3-step confirmation process:
        1. Provide current password
        2. Enter a new password
        3. Reenter said new password
    Upon completion of all three steps, a confirmation message is printed, and the user is taken back to the Main Menu.
- Log Out
    - The user is logged out of their account and taken back to the Login page.
- Delete Account
    - The user can delete their account (after confirming, following an "Are you sure?" message)
    - Following deletion, the user sees a slightly guilt-inducing farewell message and is then redirected to the login page