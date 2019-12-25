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
		@grid = nil
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
				elsif tile.visited?
					print tile.type.colorize(:green)
				else
					print tile
				end
			end
			print "\n"
		end
		print "\n"
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

	# Results: A,B,B,A,C,A,C,A,C,B
	# A: L6,R12,R8
	# B: R8,R12,L12
	# C: R12,L12,L4,L4
	# Did by hand!
	def visit_scaffold
		@program.code[0] = 2
		main_routine = "A,B,B,A,C,A,C,A,C,B\n".split('').map(&:ord)
		func_a = "L,6,R,12,R,8\n".split('').map(&:ord)
		func_b = "R,8,R,12,L,12\n".split('').map(&:ord)
		func_c = "R,12,L,12,L,4,L,4\n".split('').map(&:ord)
		continuous_video_feed = "y\n".split('').map(&:ord)
		input = main_routine + func_a + func_b + func_c + continuous_video_feed

		@grid = create_grid(input) # Got 742673, nice.
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
							(@grid[y][x].visited? && !@grid[y][x].intersection?) ||
							@solutions.length > 0 # Only finding one solution

		current = @grid[y][x]
		current.mark_visited
		solution << steps
		# display_grid([y, x])
		# sleep (0.05)
		# system('clear')
		if nbr_visited == @scaffold_nbr
			@solutions << compress_solution(solution)
		else
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

	def create_grid(input = nil)
		grid = []
		row = []
		while 42
			output = @program.run_code(input)
			p output
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
# b.display_grid
# p b.sum_of_alignment_parameters
# b.traverse
# p b.solutions[0]
p b.visit_scaffold

# Instructions * 2 since commas have to be included

