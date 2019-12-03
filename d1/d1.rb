def fuel_required(mass)
	(mass / 3) - 2
end

def true_fuel_required(mass)
	fuel = fuel_required(mass)
	return 0 if (fuel <= 0)

	return fuel + true_fuel_required(fuel)
end

def get_total_fuel(input)
	fuel_total = 0
	File.foreach(input) { |line| fuel_total += true_fuel_required(line.chomp.to_i) }
	return fuel_total
end

puts get_total_fuel('input.txt')
