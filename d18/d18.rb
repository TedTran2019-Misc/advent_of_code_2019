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
	def display_maze(maze, current)
		system('clear')
		maze.each_with_index do |row, y|
			row.each_with_index do |ele, x|
				if current == [y, x]
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

		steps
	end

	private

	def deep_dup(ele)
		if ele.is_a? Array
			arr = []
			ele.each { |e| arr << deep_dup(e) }
			return arr
		else
			return ele.dup
		end
	end

	# Hmm, error if starting node isn't valid
	# Optimized kinda by only dupping maze if it's a valid node
	# Keeping track of visited and not backtracking unless a new key is found
	# Maybe a way to remove useless nodes? Need a heuristic.
	def generate_children(node)
		curr_tile = node.maze[node.y][node.x]
		curr_face = curr_tile.type
		return [] if curr_tile.visited
		if @keys[curr_face] && node.keys[curr_face].nil?
			node.keys[curr_face] = true
			reset_all_to_unvisited(node.maze)
		end
		return nil if node.keys.length == @nbr_keys

		curr_tile.mark_visited
		children = []
		DIRS.each do |dy, dx|
			x = dx + node.x
			y = dy + node.y
			next if out_of_bounds?(x, y)
			tile = node.maze[y][x]
			face = tile.type
			next if tile.visited ||
							face == '#' ||
							(!@doors[face].nil? && node.keys[face.downcase].nil?)

			children << Node.new(node.keys.dup, dx + node.x, dy + node.y, deep_dup(node.maze))
		end

		children
	end

	def reset_all_to_unvisited(maze)
		maze.each do |row|
			row.each { |tile| tile.unmark_visited }
		end
	end

	def out_of_bounds?(x, y)
		x < 0 || y < 0 ||
		x > @maze[0].length || y > @maze.length
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
	attr_accessor :keys, :x, :y, :maze

	def initialize(keys, x, y, maze)
		@keys = keys
		@x = x
		@y = y
		@maze = maze
	end
end

a = File.read('input.txt').chomp

# 8
a = '#########
#b.A.@.a#
#########'

# 86
a = '########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################'

# 132
a = '########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################'

# 136
a = '#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################'

=begin
# 81
a = '########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################'
=end

b = TritonBeam.new(a)
p b.shortest_path_to_collect_all_keys
