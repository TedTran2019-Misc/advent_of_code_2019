# I'm too drunk for this.
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

require 'byebug'
def parse_code(code)
	start = 0
	relative_base = 0
	# orig_length = code.length

	while (start < code.length)
	# while (start < orig_length)
		opcode = code[start] % 100
		command = code[start].to_s
		value_arr = []

		# debugger if command = '203'

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
			code[value_arr[0]] = gets.chomp.to_i
		when 4
			puts value_arr[0]
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

	code
end

# parse_code(get_input('109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99'))
# parse_code(get_input('1102,34915192,34915192,7,4,7,99,0'))
# parse_code(get_input('104,1125899906842624,99'))
parse_code(get_input('input.txt', true))
