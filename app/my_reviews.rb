def my_reviews(user)
    prompt = TTY::Prompt.new
    if user.reviews.length > 0
        resp = prompt.select("Here are #{user.name}'s reviews:", user.reviews.map{ |rev| rev.site.name } + ["Back"])
        if resp == "Back"
            return
        else
            rev = user.reviews.find {|review| review.site.name == resp }
            puts "Site: #{rev.site.name}\nLocation: #{rev.site.destination.name}\nRating: #{rev.rating} - #{rev.content }\n\n"
        end
        resp = prompt.select("Options", ["Delete", "Edit", "Back"])
        case resp
        when "Back"
            return
        when "Delete"
            Review.destroy(rev.id)
        when "Edit"
            resp = prompt.select("Choose what to edit", ["Rating", "Content", "Back"])
            case resp
            when "Rating"
                rev.update(rating: prompt.slider("Choose new rating", min: 0, max: 10))
            when "Content"
                new_review = prompt.ask("Rewrite your review")
                resp = prompt.select("Are you sure?", ["Yes", "No"])
                if resp == "Yes"
                    rev.update(content: new_review)
                else
                    my_reviews(user)
                end
            when "Back"
                my_reviews(user)
            end
        end
         
    else
        puts "#{user.name} has no reviews... yet!"
    end

end