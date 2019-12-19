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

	attr_reader :oxygen_system_pos

	def initialize(program, size)
		@program = program
		@grid = Array.new(size) { Array.new(size, 0) }
		@visited_grid = Array.new(size) { Array.new(size, 0) }
		@starting_pos = [size / 2, size / 2]
		@size = size
		@oxygen_system_pos = nil
	end

	def min_steps
		x, y = @starting_pos
		@grid[y][x] = '.'
		fewest_steps(x, y, 0)
	end

	def display_grid
		@grid.each do |row|
			row.each do |ele|
				print "#{ele} "
			end
			print "\n"
		end
	end

	# Usage of two queues in this BFS to get number of steps
	# Starting oxygen doesn't count + takes an extra step to see if next_step is empty
	def oxygen_fill
		steps = -2
		current_step = [@oxygen_system_pos]
		next_step = []

		until current_step.empty? && next_step.empty?
			until current_step.empty?
				y, x = current_step.shift
				if @grid[y][x] == '.' || ([y, x] == @oxygen_system_pos)
					@grid[y][x] = 'O'
					DIRS.values.each do |dir|
						dy, dx = dir
						next_step << [y + dy, x + dx]
					end
				end
			end

			system('clear')
			display_grid
			sleep(0.05)

			current_step, next_step = next_step, current_step
			steps += 1
		end

		steps
	end

	private

	# Assuming droid starts on empty space
	def fewest_steps(x, y, steps)
		return nil if out_of_bounds?(x, y) || previously_visited?(x, y)
		mark_visited(x, y)
		min_steps = nil

		(1..4).each do |movement_command|
			status_code = @program.run_code([movement_command])
			dy, dx = DIRS[movement_command]
			case status_code
			when 0
				@grid[y + dy][x + dx] = '#'
				next
			when 1
				@grid[y + dy][x + dx] = '.'
				pos_min = fewest_steps(x + dx, y + dy, steps + 1)
				unless pos_min.nil?
					min_steps = pos_min if min_steps.nil? || (pos_min < min_steps)
				end
				@program.run_code([OPP[movement_command]])
			when 2
				@grid[y + dy][x + dx] = 'O'
				pos_min = steps + 1
				if min_steps.nil? || (pos_min < min_steps)
					min_steps = pos_min
					@oxygen_system_pos = [y + dy, x + dx]
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
		@visited_grid[y][x] == 1
	end

	def mark_visited(x, y)
		@visited_grid[y][x] = 1
	end

	def mark_unvisited(x, y)
		@visited_grid[y][x] = 0
	end
end

a = Intcode.new('input.txt', true)
droid = RepairDroid.new(a, 42)
droid.min_steps
droid.display_grid
p droid.oxygen_fill
