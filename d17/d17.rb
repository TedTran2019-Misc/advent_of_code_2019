require_relative 'lib/intcode'

# ASCII code: [35 == #] [46 == .] [10 = \n]
# Robot visible as < ^ > v
# When drawn as dir, always on scaffold. If X, tumbling through space.
# Forms a path but also loops back onto self
# Alignment parameter of scaffold intersections: x_idx - x_start * y_idx - y_start
# Find sum of alignment parameters
# What is an intersection? -> scaffolds in all 4 dirs

class ASCII
	def initialize(program)
		@program = program
		@grid = create_grid
	end

	def display_grid
		@grid.each { |row| puts row }
	end

	private

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

a = Intcode.new('input.txt', true)
b = ASCII.new(a)
b.display_grid
