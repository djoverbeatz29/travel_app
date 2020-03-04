def my_reviews(user)
    if user.reviews.length > 0
        print "Here are #{user.name}'s reviews:\n\n"
        user.reviews.each { |rev| print "Site: #{rev.site.name}\nLocation: #{rev.site.destination.name}\nRating: #{rev.rating} - #{rev.content }\n\n" }
    else
        puts "#{user.name} has no reviews... yet!"
    end
    resp = TTY::Prompt.new.select("Options", ["Exit"])
    if resp
        return
    end
end