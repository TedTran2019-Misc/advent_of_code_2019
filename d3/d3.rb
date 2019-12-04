require 'colorize'

# Premature optimization is the root of all evil.
# Plan approach before diving into problem
# Single responsibility principle
# Next time, make a class instead
# When refactoring, make sure to understand what your code does. Else, adding
# things can break the code in strange ways.

# Two wires!
# Find intersection between two wires closest to starting point
# Manhattan distance to judge, (x1 - x2).abs + (y1 - y2).abs
# Don't count starting point or crossing w/ itself
# Grab input (File or text) -> parse input -> change grid -> see dist. from starting
# This whole thing would probably be better as a class -> easier encapsulation
# [0, 0] is the top-left corner
# Second question-- only need to count the number of steps to reach the
# intersection the first time for each wire. Store in a dict! Sum later
# along with other wire to find out lowest! -> Store all reached points, because
# first wire will have no intersections
# This part had a lot of problems due to scope issues... array as hashes, but
# mainly scope issues goddamn. This should not have taken 3 hours, even if I
# wasn't focused at all and extremely distracted.

# Gets input from file or string and parses it into easy-to-use format
def grab_input(input, file = false)
	input = File.read(input) if file
	input.split("\n").map { |orders| orders.split(',') }
end

# Modifying this function to able to complete second part
def find_intersection_dist(size, starting_pos, input, file)
	grid = Array.new(size) { Array.new(size) }
	grid[starting_pos[0]][starting_pos[1]] = 'O'
	hash_arr = [{}, {}] # 0 and 1
	command_lists = grab_input(input, file)
	command_lists.each_with_index { |list, i| change_grid(grid, list, starting_pos, i, hash_arr[i]) }
	p shortest_manhattan_distance(grid, starting_pos)
	p least_number_steps(hash_arr[0], hash_arr[1])
end

# Hash 1 and Hash 2
def least_number_steps(wire1, wire2)
	min = nil

	wire2.each do |key, val|
		value = wire1[key] + val
		min = value if (min.nil? || (min > value))
	end

	min
end

def shortest_manhattan_distance(grid, start)
	intersection_points = []
	grid.each_with_index do |row, y|
		row.each_with_index do |ele, x|
			intersection_points.push([y, x]) if ele == 'X'
		end
	end
	intersection_points.map { |point| manhattan_distance(point, start) }.min
end

def manhattan_distance(point, starting_points)
	(starting_points[0] - point[0]).abs + (starting_points[1] - point[1]).abs
end

def print_grid(grid)
	grid.each do |row|
		row.each do |ele|
			if ele.nil?
				print 'n'
			else
				print ele.to_s.colorize(:blue)
			end
			print ' '
		end
		print "\n"
	end
end

# i for index and identifier
def change_grid(grid, list, starting_pos, i, hash)
	pos = starting_pos.dup
	total_steps = 0
	list.each do |command|
		dir = command[0]
		mag = command[1..-1].to_i
		draw_path(grid, pos, dir, mag, i, total_steps, hash)
		total_steps += mag
	end
end

def change_hash(i, total_steps, hash, identifier, pos)
	if (i == 0)
		hash[pos] = total_steps unless hash.has_key?(pos)
	elsif (i == 1)
		if (identifier == 'X')
			hash[pos] = total_steps unless hash.has_key?(pos)
		end
	end
end

# [y, x]
def draw_path(grid, pos, dir, mag, i, total_steps, hash)
	y = pos[0]
	x = pos[1]

	case dir
	when 'U'
		(1..mag).each do |step|
			filled = grid[y - step][x]
			identifier = choose_identifier(filled, i)
			# next unless identifier
			pos[0] = pos[0] - 1
			grid[y - step][x] = identifier if identifier
			# pos[0] = pos[0] - step if mag == step
			total_steps += 1
			change_hash(i, total_steps, hash, identifier, pos.to_s)
		end
	when 'R'
		(1..mag).each do |step|
			filled = grid[y][x + step]
			identifier = choose_identifier(filled, i)
			# next unless identifier
			grid[y][x + step] = identifier if identifier
			pos[1] = pos[1] + 1
			# pos[1] = pos[1] + step if mag == step
			total_steps += 1
			change_hash(i, total_steps, hash, identifier, pos.to_s)
		end
	when 'D'
		(1..mag).each do |step|
			filled = grid[y + step][x]
			identifier = choose_identifier(filled, i)
			# next unless identifier
			grid[y + step][x] = identifier if identifier
			pos[0] = pos[0] + 1
			# pos[0] = pos[0] + step if mag == step
			total_steps += 1
			change_hash(i, total_steps, hash, identifier, pos.to_s)
		end
	when 'L'
		(1..mag).each do |step|
			filled = grid[y][x - step]
			identifier = choose_identifier(filled, i)
			# next unless identifier
			grid[y][x - step] = identifier if identifier
			pos[1] = pos[1] - 1
			# pos[1] = pos[1] - step if mag == step
			total_steps += 1
			change_hash(i, total_steps, hash, identifier, pos.to_s)
		end
	else
		raise 'Invalid dir'
	end
end

# nil for skip, else choose identifier
def choose_identifier(filled, i)
	if filled.nil?
		i
	elsif ['O', 'X', i].include?(filled)
		nil
	else
		'X'
	end
end

find_intersection_dist(30, [15, 15],
'R8,U5,L5,D3
U7,R6,D4,L4', false)

find_intersection_dist(500, [250, 250],
'R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83', false)

find_intersection_dist(500, [250, 250],
'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7', false)

# LMAO. This took a billion yers to load.
find_intersection_dist(12000, [6000, 6000], 'input.txt', true)
