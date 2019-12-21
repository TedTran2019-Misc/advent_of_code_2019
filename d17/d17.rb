require_relative 'lib/intcode'
require_relative 'lib/tile'

# ASCII code: [35 == #] [46 == .] [10 = \n]
# Robot visible as < ^ > v
# When drawn as dir, always on scaffold. If X, tumbling through space.

class ASCII
	attr_reader :program, :grid

	DIRS = [
		[-1, 0],
		[1, 0],
		[0, -1],
		[0, 1]
	]

	def initialize(program)
		@program = program
		@grid = create_grid
	end

	def display_grid
		@grid.each do |row|
			row.each do |tile|
				print tile
			end
			print "\n"
		end
	end

	def sum_of_alignment_parameters
		sum = 0
		@grid.each_with_index do |row, y|
			row.each_with_index do |ele, x|
				if ele.type == "#" && is_intersection?(x, y)
					sum += (x * y)
					@grid[y][x].is_intersection
				end
			end
		end
		sum
	end

	private

	def is_intersection?(x, y)
		DIRS.all? do |dir|
			dy, dx = dir
			!out_of_bounds(x + dx, y + dy) && @grid[y + dy][x + dx].type == '#'
		end
	end

	def out_of_bounds(x, y)
		x < 0 || y < 0 || y >= @grid.length || x >= @grid[0].length
	end

	def create_grid
		grid = []
		row = []
		while 42
			output = @program.run_code
			break if output.nil?

			output = output.chr
			if output == "\n"
				grid << row
				row = []
			else
				row << Tile.new(output)
			end
		end
		grid[0...-1] # Dealing with newline at end of text file resulting in extra []
	end
end

p1 = Intcode.new('input.txt', true)
b = ASCII.new(p1)
b.display_grid
p b.sum_of_alignment_parameters

# For part 2, finding the shortest path to cover all of scaffold doesn't matter
# Need to just fit within limit of 20 chars for main routine and movement funcs
# How to determine if I should go back upon a path or not? -> Intersection
# If intersection, can go back upon. If next one after intersection is already
# visited, return
# Upon reaching an intersection, decide course of action
# Choose that can fit within limits: (3), within 20 chars for movement funcs
# 20 for main routine
