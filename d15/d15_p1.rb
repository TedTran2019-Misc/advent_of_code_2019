require_relative 'intcode'

# Repair droid controlled by Intcode program
# Infinite loop: accept movement, send movement, finish operation, report status
# north (1), south (2), west (3), east (4). Diff direction, same distance
# 0: wall same pos, 1: moved one step, 2: moved one step and reached oxygen sys
# Fewest steps to move repair droid to oxygen system? BFS.
# Going to utilize DFS so I don't need to backtrack as much
class RepairDroid
	OPP = {
		1 => 2,
		2 => 1,
		3 => 4,
		4 => 3
	}

	DIRS = {
		1 => [-1, 0],
		2 => [1, 0],
		3 => [0, -1],
		4 => [0, 1]
	}

	def initialize(program, size)
		@program = program
		@grid = Array.new(size) { Array.new(size, 0) }
		@starting_pos = [size / 2, size / 2]
		@size = size
	end

	def min_steps
		x, y = @starting_pos
		fewest_steps(x, y, 0)
	end

	private

	# What if the droid started on the oxygen system?
	def fewest_steps(x, y, steps)
		return nil if out_of_bounds?(x, y) || previously_visited?(x, y)
		mark_visited(x, y)
		min_steps = nil

		(1..4).each do |movement_command|
			status_code = @program.run_code([movement_command])
			dy, dx = DIRS[movement_command]
			case status_code
			when 0
				next
			when 1
				pos_min = fewest_steps(x + dx, y + dy, steps + 1)
				unless pos_min.nil?
					min_steps = pos_min if min_steps.nil? || (pos_min < min_steps)
				end
				@program.run_code([OPP[movement_command]])
			when 2
				pos_min = steps + 1
				if min_steps.nil? || (pos_min < min_steps)
					min_steps = pos_min
				end
				@program.run_code([OPP[movement_command]])
			end
		end

		mark_unvisited(x, y)
		min_steps
	end

	def out_of_bounds?(x, y)
		y < 0 || x < 0 || y >= @size || x >= @size
	end

	def previously_visited?(x, y)
		@grid[y][x] == 1
	end

	def mark_visited(x, y)
		@grid[y][x] = 1
	end

	def mark_unvisited(x, y)
		@grid[y][x] = 0
	end
end

a = Intcode.new('input.txt', true)
p RepairDroid.new(a, 500).min_steps
