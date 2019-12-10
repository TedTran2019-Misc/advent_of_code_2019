def get_input(input, filename = false)
	if filename
		File.foreach(input) { |line| return line.chomp.split(',').map { |char| char.to_i } }
	else
		return input.split(',').map { |char| char.to_i }
	end
end

def parse_code(code)
	start = 0
	while (start < code.length)
		opcode = code[start] % 100
		command = code[start].to_s
		value_arr = []

		break if opcode == 99
		if [1, 2, 7, 8].include?(opcode)
			command = command.rjust(5, '0') # Move forward 4
		elsif [3, 4].include?(opcode)
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
		(command.length - 3).downto(0).each do |i|
			if (i == 0 && !opcode.between?(4, 6))
				value_arr.push(code[start])
			elsif command[i] == '1'
				value_arr.push(code[start])
			elsif command[i] == '0'
				value_arr.push(code[code[start]])
			else
				raise 'Invalid'
			end

			start += 1
		end

		# 1-3, 7-8 take address as final always, 4-6 can or cannot.
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
		else
			raise 'Invalid opcode'
		end
	end

	code
end
