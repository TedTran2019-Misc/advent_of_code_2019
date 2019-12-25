# Puzzle Input - Map
# Entrance marked '@'
# Open passages: '.', Walls: '#'
# Doors are uppercase letters, need keys, corresponding lowercase letters
# Need to collect all keys in fewest steps possible
# Can do BFS, DFS wouldn't work since you'd have to backtrack visited tiles
# How to store which keys you have and which doors can be accessed?
# Each node stores the amount of keys it has at that point in time
# Parent node gives children nodes a dup of key dict

class TritonBeam
	attr_reader :keys, :starting_coors, :maze, :nbr_keys

	DIRS = [
		[-1, 0],
		[0, 1],
		[1, 0],
		[0, -1]
	]

	def initialize(input)
		@nbr_keys = 0
		@starting_coor = nil
		@keys, @doors = create_key_door_dicts
		@maze = create_maze(input)
		@current = @starting_coor # For display purposes
	end

	require 'colorize'
	def display_maze
		system('clear')
		@maze.each_with_index do |row, y|
			row.each_char.with_index do |ele, x|
				if @current == [y, x]
					print ele.colorize(:red)
				else
					print ele
				end
			end
			print "\n"
		end
		print "\n"
	end

	# Basic BFS
	def shortest_path_to_collect_all_keys
		y, x = @starting_coor
		queue = [Node.new({}, x, y)]
		steps = 0
		until queue.empty?
			p queue
			sleep(3)
			new_queue = []
			queue.each do |node|
				children = generate_children(node)
				if children.is_a? Array
					new_queue.concat(children)
				else
					return steps
				end
			end
			steps += 1
			queue = new_queue
		end
	end

	private

	def generate_children(node)
		return [] if out_of_bounds?(node)
		tile = @maze[node.y][node.x]
		return [] if tile == '#' ||
								 (!@doors[tile].nil? && node.keys[tile.lowercase].nil?)
		node.keys[tile] = true if @keys[tile]
		return nil if node.keys.length == @nbr_keys

		@current = [node.y, node.x]
		display_maze
		sleep(3)

		children = []
		DIRS.each do |dy, dx|
			children << Node.new(node.keys.dup, dx + node.x, dy + node.y)
		end

		children
	end

	def out_of_bounds?(node)
		node.x < 0 || node.y < 0 ||
		node.x > @maze[0].length || node.y > @maze.length
	end

	def create_maze(input)
		maze = []
		input.each_line.with_index do |row, y|
			row = row.chomp
			maze_row = ""
			row.each_char.with_index do |ele, x|
				@nbr_keys += 1 unless @keys[ele].nil?
				@starting_coor = [y, x] if ele == '@'
				maze_row << ele
			end
			maze << maze_row
		end
		maze
	end

	def create_key_door_dicts
		key_dict = {}
		door_dict = {}

		('a'..'z').each do |letter|
			upper = letter.upcase
			key_dict[letter] = upper
			door_dict[upper] = letter
		end

		[key_dict, door_dict]
	end
end

class Node
	attr_accessor :keys, :x, :y

	def initialize(keys, x, y)
		@keys = keys
		@x = x
		@y = y
	end
end

a = File.read('input.txt').chomp
b = TritonBeam.new(a)
b.shortest_path_to_collect_all_keys
