# Puzzle Input - Map
# Entrance marked '@'
# Open passages: '.', Walls: '#'
# Doors are uppercase letters, need keys, corresponding lowercase letters
# Need to collect all keys in fewest steps possible
# How to store which keys you have and which doors can be accessed?
# Each node stores the amount of keys it has at that point in time
# Parent node gives children nodes a dup of key dict
require_relative 'bit_array'

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
		@height = @maze.length
		@width = @maze[0].length
	end

	require 'colorize'
	def display_maze(current = nil)
		# system('clear')
		@maze.each_with_index do |row, y|
			row.each_with_index do |ele, x|
				if current == [y, x]
					print ele.colorize(:red)
				else
					print ele
				end
			end
			print "\n"
		end
		print "\n"
	end

	# Even with a bitfield, it's highly naive.
	# Hmm, this problem was kind of ruined for me because I stumbled upon advice
	# that said 'BFS' then I didn't think about the problem myself at all. I just
	# implemented a basic BFS without thinking about the consequences or how to
	# optimize. Would DFS have been better here? Maybe a more clever solution than a
	# bruteforce BFS? Let's refactor and come up with an entirely new solution.
	def shortest_path_to_collect_all_keys
		y, x = @starting_coor
		queue = [Node.new({}, x, y, BitArray.new)]
		steps = 0
		until queue.empty?
			new_queue = []
			queue.each do |node|
				# display_maze([node.y, node.x])
				children = generate_children(node)
				if children.is_a? Array
					new_queue.concat(children)
				else
					return steps
				end
			end


			new_queue.uniq! { |node| [node.keys, node.x, node.y] } # Repeats
			p steps
			p new_queue.length

			steps += 1
			queue = new_queue
		end

		steps
	end

	private

	# Let's try to use a bitfield to store 1/0s
	# array[width * height] is size
	# To access and get values, (width * row_idx) + col_idx
	def generate_children(node)
		curr_tile = @maze[node.y][node.x]
		pos = (@width * node.y) + node.x
		if @keys[curr_tile] && node.keys[curr_tile].nil?
			node.keys[curr_tile] = true
			node.maze = BitArray.new
		end
		return nil if node.keys.length == @nbr_keys

		node.maze[pos] = 1
		children = []
		DIRS.each do |dy, dx|
			x = dx + node.x
			y = dy + node.y
			next if out_of_bounds?(x, y)
			new_pos = (@width * y) + x
			tile = @maze[y][x]
			next if node.maze[new_pos] == 1 ||
							tile == '#' ||
							(!@doors[tile].nil? && node.keys[tile.downcase].nil?)

			children << Node.new(node.keys.dup, x, y, node.maze.dup)
		end

		children
	end

	def out_of_bounds?(x, y)
		x < 0 || y < 0 ||
		x > @width || y > @height
	end

	def create_maze(input)
		maze = []
		input.each_line.with_index do |row, y|
			row = row.chomp
			maze_row = []
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
	attr_accessor :keys, :x, :y, :maze

	def initialize(keys, x, y, maze)
		@keys = keys
		@x = x
		@y = y
		@maze = maze
	end
end

a = File.read('input.txt').chomp

=begin
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

# 81
a = '########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################'
=end

b = TritonBeam.new(a)
require 'byebug'
# debugger
p b.shortest_path_to_collect_all_keys
