# Puzzle Input - Map
# Entrance marked '@'
# Open passages: '.', Walls: '#'
# Doors are uppercase letters, need keys, corresponding lowercase letters
# Need to collect all keys in fewest steps possible
# How to store which keys you have and which doors can be accessed?
# Each node stores the amount of keys it has at that point in time
# Parent node gives children nodes a dup of key dict

require_relative 'tile'

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
			row.each_with_index do |ele, x|
				if @current == [y, x]
					print ele.type.colorize(:red)
				else
					print ele.type
				end
			end
			print "\n"
		end
		print "\n"
	end

	# Basic BFS
	# Issue: backtracking and inefficient solutions padding the runtime.
	# I guess an individual grid for each node, with visited marked! Visited tiles
	# are unmarked whenever a new key is found, excluding the node one is currently on.
	def shortest_path_to_collect_all_keys
		y, x = @starting_coor
		queue = [Node.new({}, x, y, deep_dup(@maze))]
		steps = 0
		until queue.empty?
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

	def deep_dup(ele)
		if ele.is_a? Array
			arr = []
			ele.each { |e| arr << e.deep_dup }
			return arr
		else
			return ele.dup
		end
	end

	# Change this once I'm back into it tomorrow
	def generate_children(node)
		return [] if out_of_bounds?(node)
		tile = @maze[node.y][node.x]
		return [] if tile == '#' ||
								 (!@doors[tile].nil? && node.keys[tile.downcase].nil?)
		node.keys[tile] = true if @keys[tile]
		return nil if node.keys.length == @nbr_keys

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
			maze_row = []
			row.each_char.with_index do |ele, x|
				@nbr_keys += 1 unless @keys[ele].nil?
				@starting_coor = [y, x] if ele == '@'
				maze_row << Tile.new(ele)
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

	def initialize(keys, x, y, maze)
		@keys = keys
		@x = x
		@y = y
		@maze = maze
	end
end

a = File.read('input.txt').chomp
a = '#########
#b.A.@.a#
#########'
a = '########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################'
b = TritonBeam.new(a)
# p b.shortest_path_to_collect_all_keys
