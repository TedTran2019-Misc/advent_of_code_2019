class Code
	attr_accessor :code

	def initialize(code)
		@code = code
	end

	def [](key)
		overindex(key)
		@code[key]
	end

	def []=(key, value)
		overindex(key)
		@code[key] = value
	end

	def length
		@code.length
	end

	private

	def overindex(key)
		if key >= @code.length
			raise 'No negative indexes!' if key < 0
			pad_array(key, 0)
		end
	end

	def pad_array(key, val)
		number_missing_elements = key - (@code.length - 1)
		@code.concat(Array.new(number_missing_elements, val))
	end
end

def get_input(input, filename = false)
	code = nil
	if filename
		code = File.read(input).split(',').map { |char| char.to_i }
	else
		code = input.split(',').map { |char| char.to_i }
	end
	Code.new(code)
end

def parse_code(code, start, relative_base, input = false)
	while (start < code.length)
		opcode = code[start] % 100
		command = code[start].to_s
		value_arr = []

		break if opcode == 99
		if [1, 2, 7, 8].include?(opcode)
			command = command.rjust(5, '0') # Move forward 4
		elsif [3, 4, 9].include?(opcode)
			command = command.rjust(3, '0') # Move forward 2
		elsif [5, 6].include?(opcode)
			command = command.rjust(4, '0') # Move forward 3
		else
			raise 'Invalid opcode'
		end

		start += 1 # Move forward one after grabbing instruction

		# 0 is position while 1 is intermediate
		# 2 is relative mode-- similar to position mode.
		# Interpreted as position, but count from relative base instead of address 0.
		# i == 0 is for the inconsistency...
		# Parameters that an instruction writes will never be in immediate mode
		(command.length - 3).downto(0).each do |i|
			if i == 0 && [1, 2, 3, 7, 8].include?(opcode) # Literal mode cases
				if command[i] == '2'
					value_arr.push(code[start] + relative_base)
				else
					value_arr.push(code[start])
				end
			elsif command[i] == '1'
				value_arr.push(code[start])
			elsif command[i] == '0'
				value_arr.push(code[code[start]])
			elsif command[i] == '2'
					value_arr.push(code[code[start] + relative_base])
			else
				raise 'Invalid'
			end

			start += 1
		end

		# 1-3, 7-8 take address as final always, 4-6 and 9 can or cannot.
		case opcode
		when 1
			code[value_arr[2]] = value_arr[0] + value_arr[1]
		when 2
			code[value_arr[2]] = value_arr[0] * value_arr[1]
		when 3
			code[value_arr[0]] = input ? input.shift : gets.chomp.to_i
		when 4
			# p value_arr[0]
			return [value_arr[0], start, relative_base]
		when 5
			start = value_arr[1] unless value_arr[0].zero?
		when 6
			start = value_arr[1] if value_arr[0].zero?
		when 7
			code[value_arr[2]] = (value_arr[0] < value_arr[1] ? 1 : 0)
		when 8
			code[value_arr[2]] = (value_arr[0] == value_arr[1] ? 1 : 0)
		when 9
			relative_base += value_arr[0]
		else
			raise 'Invalid opcode'
		end
	end

	nil
end

###############################################################################
# 3 outputs
# Distance from left
# Distance from top
# Tile ID: empty, wall, block, horizontal paddle, ball
# Meh, don't feel like making an infinite grid so I'll just do this.
# If so, can do it the same way as Code class but with rows and grid
code = get_input('input.txt', true)

def draw_grid(size, code)
	start = 0
	relative_base = 0
	grid = Array.new(size) { Array.new(size) }
	while 42
		x_pos_start_relative_base = parse_code(code, start, relative_base)
		break if x_pos.nil?
		x_pos = x_pos_start_relative_base[0] # Dealing with nil case
		start =  x_pos_start_relative_base[1]
		relative_base = x_pos_start_relative_base[2]
		y_pos, start, relative_base = parse_code(code, start, relative_base)
		tile_id, start, relative_base = parse_code(code, start, relative_base)

		grid[y_pos][x_pos] = tile_id
	end

	# grid.inject(0) do |accu, row|
	# 	accu + row.inject(0) { |accu, nbr| nbr == 2 ? accu + 1 : accu }
	# end

	#grid
	play_game(code, grid, start, relative_base)
end

require 'colorize'
def display_grid(grid)
	grid.each do |row|
		row.each do |el|
			case el
			when 0
				print ' '
			when 1
				print '|'
			when 2
				print '#'.colorize(:green)
			when 3
				print '_'.colorize(:red)
			when 4
				print 'o'.colorize(:blue)
			end
		end
		print "\n"
	end
	print "\n"
end

def play_game(code, grid, start, relative_base)
	code.code[0] = 2
	input = nil
	ball_start = find_ball_x_coor(grid)
	ball_end = nil
	ball_dir = nil
	p 'bleh'

	while 42
		# system("clear")
		# display_grid(grid)
		p start, relative_base
		x, start, relative_base = parse_code(code, start, relative_base)
		break if x.nil?
		y, start, relative_base = parse_code(code, start, relative_base)
		tile_id, start, relative_base = parse_code(code, start, relative_base)

		if x == -1
			puts tile_id
		else
			grid[y][x] = tile_id
		end

		ball_end = find_ball_x_coor(grid)
		ball_dir = ball_end

	end
end

def find_ball_x_coor(grid)
	grid.each do |row|
		x_coor = row.index(4)
		return x_coor if x_coor
	end
end

draw_grid(24, code)
