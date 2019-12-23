require_relative 'lib/intcode'
require_relative 'lib/tile'

# ASCII code: [35 == #] [46 == .] [10 = \n]
# Robot visible as < ^ > v
# When drawn as dir, always on scaffold. If X, tumbling through space.

class ASCII
	attr_reader :program, :grid, :scaffold_nbr, :solutions

	# Idx 0-3, North-East-South-West
	DIRS = [
		[-1, 0],
		[0, 1],
		[1, 0],
		[0, -1]
	]

	def initialize(program)
		@program = program
		@grid = create_grid
		@scaffold_nbr = 1 # Accounting for robot on scaffold
		@solutions = []
	end

	def traverse
		starting_dir, starting_pos = find_starting_dir
		y, x = starting_pos
		@grid[y][x].type = '#'
		walk_scaffold(starting_dir, x, y, 0, [])
	end

	def find_starting_dir
		dirs = ['^', '>', 'v', '<']
		@grid.each_with_index do |row, y|
			row.each_with_index do |ele, x|
				return [dirs.index(ele.type), [y, x]] if dirs.include?(ele.type)
			end
		end
	end

	require 'colorize'
	def display_grid(current = nil)
		@grid.each_with_index do |row, y|
			row.each_with_index do |tile, x|
				if current && current == [y, x]
					print tile.type.colorize(:red)
				else
					print tile
				end
			end
			print "\n"
		end
	end

	def sum_of_alignment_parameters
		sum = 0
		@grid.each_with_index do |row, y|
			row.each_with_index do |ele, x|
				if ele.type == "#"
					@scaffold_nbr += 1
					if is_intersection?(x, y)
						sum += (x * y)
						@grid[y][x].set_intersection
					end
				end
			end
		end
		sum
	end

	private

	def compress_solutions
		@solutions.map! do |solution|
			compress_solution(solution)
		end
	end

	def compress_solution(solution)
		compressed = []
		solution.each_with_index do |ele, idx|
			next if ele == 0
			after = solution[idx + 1]
			compressed << ele if ['R', 'L'].include?(ele)
			compressed << ele if ['R', 'L', nil].include?(after)
		end

		compressed
	end

	def walk_scaffold(dir, x, y, steps, solution)
		return if out_of_bounds?(x, y) ||
							@grid[y][x].type != '#' ||
							(@grid[y][x].visited? && !@grid[y][x].intersection?)

		current = @grid[y][x]
		current.mark_visited unless current.visited?
		solution << steps
		k = nbr_visited
		# display_grid([y, x])
		# p k
		# sleep (0.2)
		if k == @scaffold_nbr
			@solutions << compress_solution(solution)
			return
		end

		[dir, right(dir), left(dir)].each_with_index do |new_dir, i|
			dy, dx = DIRS[new_dir]
			if i == 0
				walk_scaffold(dir, x + dx, y + dy, steps + 1, solution)
			else
				turn = (i == 1 ? 'R' : 'L')
				solution << turn
				walk_scaffold(new_dir, x + dx, y + dy, 1, solution)
				solution.pop
			end
		end

		current.mark_unvisited
		solution.pop
	end

	def nbr_visited
		visited = 0
		@grid.each do |row|
			row.each { |ele| visited += 1 if ele.visited? }
		end

		visited
	end

	def right(idx)
		(idx + 1) % 4
	end

	def left(idx)
		(idx - 1) % 4
	end

	def is_intersection?(x, y)
		DIRS.all? do |dir|
			dy, dx = dir
			!out_of_bounds?(x + dx, y + dy) && @grid[y + dy][x + dx].type == '#'
		end
	end

	def out_of_bounds?(x, y)
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
b.traverse
p b.solutions.length

# For part 2, finding the shortest path to cover all of scaffold doesn't matter
# Need to just fit within limit of 20 chars for main routine and movement funcs
# How to determine if I should go back upon a path or not? -> Intersection
# If intersection, can go back upon. If next one after intersection is already
# visited, return
# Upon reaching an intersection, decide course of action
# Choose that can fit within limits: (3), within 20 chars for movement funcs
# 20 for main routine
# Recursive, get all possible solutions utilizing rules. Need to turn or intersection
# Once you have a solution compress it
