require_relative 'code'

class Intcode
	attr_accessor :code, :start, :relative_base
	attr_reader :return_mode

	def initialize(input, filename = false)
		@code = parse_code(input, filename)
		@start = 0
		@relative_base = 0
		@return_mode = true
	end

	def run_code(input = false)
		while (@start < @code.length)
			opcode = @code[@start] % 100
			command = @code[@start].to_s

			break if opcode == 99
			command = command_setup(opcode, command)
			@start += 1

			value_arr = create_value_arr(opcode, command)

			output = opcode(opcode, value_arr, input)
			return output unless output.nil?
		end

		nil
	end

	def return_on
		@return_mode = true
		self
	end

	def return_off
		@return_mode = false
		self
	end

	private

	# 0 is position, 1 is intermediate, 2 relative (Like 0, but count from rel base)
	# Parameters that an instruction writes will never be in immediate mode
	def create_value_arr(opcode, command)
		value_arr = []
		(command.length - 3).downto(0).each do |i|
			if i == 0 && [1, 2, 3, 7, 8].include?(opcode) # Literal mode cases
				value = @code[@start]
				value += @relative_base if command[i] == '2'
				value_arr.push(value)
			elsif command[i] == '1'
				value_arr.push(@code[@start])
			elsif command[i] == '0'
				value_arr.push(@code[@code[@start]])
			elsif command[i] == '2'
					value_arr.push(@code[@code[@start] + @relative_base])
			else
				raise 'Invalid'
			end

			@start += 1
		end

		value_arr
	end

	def command_setup(opcode, command)
		if [1, 2, 7, 8].include?(opcode)
			command.rjust(5, '0') # Move forward 4
		elsif [3, 4, 9].include?(opcode)
			command.rjust(3, '0') # Move forward 2
		elsif [5, 6].include?(opcode)
			command.rjust(4, '0') # Move forward 3
		else
			raise 'Invalid opcode'
		end
	end

	# [1-3, 7-8] take address as final always, [4-6,9] can or cannot.
	def opcode(opcode, value_arr, input)
		case opcode
		when 1
			@code[value_arr[2]] = value_arr[0] + value_arr[1]
		when 2
			@code[value_arr[2]] = value_arr[0] * value_arr[1]
		when 3
			@code[value_arr[0]] = input ? input.shift : gets.chomp.to_i
			# return 'input received' if @return_mode
		when 4
			return value_arr[0] if @return_mode
			p value_arr[0]
		when 5
			@start = value_arr[1] unless value_arr[0].zero?
		when 6
			@start = value_arr[1] if value_arr[0].zero?
		when 7
			@code[value_arr[2]] = (value_arr[0] < value_arr[1] ? 1 : 0)
		when 8
			@code[value_arr[2]] = (value_arr[0] == value_arr[1] ? 1 : 0)
		when 9
			@relative_base += value_arr[0]
		else
			raise 'Invalid opcode'
		end

		nil
	end

	def parse_code(input, filename)
		code = (filename ? File.read(input) : input)
		code = code.split(',').map(&:to_i)
		Code.new(code)
	end
end

# Testing refactored Intcode computer
=begin
a = '109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99'
b = '1102,34915192,34915192,7,4,7,99,0'
c = '104,1125899906842624,99'
Intcode.new(a).return_off.run_code
Intcode.new(b).return_off.run_code
Intcode.new(c).return_off.run_code
Intcode.new('test_intcode.txt', true).return_off.run_code
=end
