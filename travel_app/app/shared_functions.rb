def month_max(mo, year = Time.now.year)
    if mo == 2
        if year % 4 !=0 || (year % 100 == 0 && year % 400 != 0)
            28
        else
            29
        end
    elsif [4, 6, 9, 11].include?(mo)
        30
    else
        31
    end
end

