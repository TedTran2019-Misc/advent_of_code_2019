require_relative 'lib/intcode'

# ASCII code: [35 == #] [46 == .] [10 = \n]
# Robot visible as < ^ > v
# When drawn as dir, always on scaffold. If X, tumbling through space.

class ASCII
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
		@grid.each { |row| puts row }
	end

	def sum_of_alignment_parameters
		sum = 0
		@grid.each_with_index do |row, y|
			row.each_char.with_index do |ele, x|
				sum += (x * y) if ele == "#" && is_intersection?(x, y)
			end
		end
		sum
	end

	private

	def is_intersection?(x, y)
		DIRS.all? do |dir|
			dy, dx = dir
			!out_of_bounds(x + dx, y + dy) && @grid[y + dy][x + dx] == '#'
		end
	end

	def out_of_bounds(x, y)
		x < 0 || y < 0 || y >= @grid.length || x >= @grid[0].length
	end

	def create_grid
		grid = []
		row = ""
		while 42
			output = @program.run_code
			break if output.nil?

			output = output.chr
			if output == "\n"
				grid << row
				row = ""
			else
				row << output
			end
		end
		grid
	end
end

p1 = Intcode.new('input.txt', true)
b = ASCII.new(p1)
b.display_grid
p b.sum_of_alignment_parameters
