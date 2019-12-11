def get_grid(input, file = false)
	if file
		File.readlines(input, chomp: true)
	else
		input.split("\n")
	end
end

def most_asteroids_detected(grid)
	max = nil
	max_coors = nil
	grid.each_with_index do |row, y1|
		row.each_char.with_index do |current, x1|
			next if current == '.'
			detected = asteroids_detected(y1, x1, grid)
			if max.nil? || detected > max
				max = detected
				max_coors = [y1, x1]
			end
		end
	end
	max_coors
end

def asteroids_detected(y1, x1, grid)
	angle_tracker = {}
	spotted = 0
	grid.each_with_index do |row, y2|
		row.each_char.with_index do |target, x2|
			next if ((y1 == y2) && (x1 == x2)) || target == '.'
			y = y2 - y1
			x = x2 - x1
			angle = Math.atan2(x, y) # Angle in radians
			# degrees = angle * (180 / Math::PI)
			unless angle_tracker.has_key?(angle)
				spotted += 1
				angle_tracker[angle] = true
			end
		end
	end
	spotted
end

# Bet: e.g 200th asteroid vaporized
# Asteroid stack! angle -> asteroids to vaporize
# 180 - 0, 360 - 180
def vaporized_asteroids_bet(grid, bet)
	raise 'How can you bet on the zeroth or negative asteroids being hit?' if bet <= 0
	landing_asteroid = most_asteroids_detected(grid)
	angle_stack = create_angle_stack(grid, landing_asteroid)
	angles_order = create_proper_order(angle_stack.keys)
	asteroids_remaining = true
	vaporized_count = 0
	while (asteroids_remaining)
		asteroids_remaining = false
		angles_order.each do |angle|
			next if angle_stack[angle].empty?
			coors = angle_stack[angle].pop
			vaporized_count += 1
			return coors if vaporized_count == bet
			asteroids_remaining = true
		end
	end

	nil
end

# To be behind, need differing y's unless on same y, then differing x.
def create_angle_stack(grid, landing_asteroid)
	angle_stack = Hash.new { |h, k| h[k] = [] }
	y1 = landing_asteroid[0]
	x1 = landing_asteroid[1]
	grid.each_with_index do |row, y2|
		row.each_char.with_index do |target, x2|
			next if ((y1 == y2) && (x1 == x2)) || target == '.'
			y = y2 - y1
			x = x2 - x1
			angle = Math.atan2(x, y)
			degrees = angle * (180 / Math::PI)
			degrees = degrees + 360 if degrees <= 0
			if (y1 == y2 && x2 > x1) || (y2 > y1) # Closest value popped first
				angle_stack[degrees].unshift([y2, x2])
			else
				angle_stack[degrees] << [y2, x2]
			end
		end
	end
	angle_stack
end

def create_proper_order(angles)
	start = angles.select { |angle| angle <= 180 }.sort { |a, b| b <=> a}
	final = angles.reject { |angle| angle <= 180 }.sort { |a, b| b <=> a }
	start + final
end

grid = get_grid('input.txt', true)
coors = vaporized_asteroids_bet(grid, 200)
p (coors[1] * 100 + coors[0])

# Why is 180 degrees the vertical up? Had to end up testing to see that, since
# I originally sorted from 0, then from 90 before realizing this. Depends on
# the coordinate system you're using?
