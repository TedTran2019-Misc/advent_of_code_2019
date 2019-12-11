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

code = get_input('input.txt', true)

	# DIRS.first is the current direction.
	DIRS = [
		[-1, 0],
		[0, -1],
		[1, 0],
		[0, 1]
	]

# Panels start black as '.' '#' is white.
# Input: 0 if robot over a black panel, 1 if over a white one
# Output: Color to paint panel robot is over, 0 for black 1 for white
# Second output: 0 turn left 90 degrees, 1 turn right 90 degrees.
# Move forward one panel after turn, start facing up.
# Intcode computer isn't restarted.
def paintbot(code, size)
	offset = [size / 2, size / 2]
	y, x = offset
	grid = Array.new(size) { '.' * size }
	grid[y][x] = '#'
	paint(code, grid, offset)
	show_grid(grid)
end

def paint(code, grid, current)
	idx = 0
	base = 0
	panels_painted = 0
	dict = {}

	while (42)
		y = current[0]
		x = current[1]

		input = (grid[y][x] == '.' ? 0 : 1)
		color_idx_base = parse_code(code, idx, base, [input])
		break if color_idx_base.nil?
		turn_idx_base = parse_code(code, color_idx_base[1], color_idx_base[2])
		base = turn_idx_base[2]
		idx = turn_idx_base[1]

		str = current.to_s
		unless dict.has_key?(str)
			panels_painted += 1
			dict[str] = true
		end

		current = paint_grid(grid, color_idx_base[0], turn_idx_base[0], y, x)
	end

	p panels_painted
end

def paint_grid(grid, color, turn, y, x)
	turn.zero? ? DIRS << DIRS.shift : DIRS.unshift(DIRS.pop)
	grid[y][x] = color.zero? ? '.' : '#'
	dy, dx = DIRS.first
	# show_grid(grid)
	[y + dy, x + dx]
end

def show_grid(grid)
	grid.each { |row| puts row }
	print "\n"
end

paintbot(code, 100)
