a = [1, 2, 3, 4, 5]

b = a.map { |e| [e, e+1] }

b.each { |x, y| puts "#{x}, #{y}"}