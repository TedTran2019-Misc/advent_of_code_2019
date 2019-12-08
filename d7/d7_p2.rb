def get_input(input, filename = false)
	if filename
		File.foreach(input) { |line| return line.chomp.split(',').map { |char| char.to_i } }
	else
		return input.split(',').map { |char| char.to_i }
	end
end

def parse_code(code, amp = false, start = 0)
	return_value = nil

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
			if amp && amp.empty?
				raises 'Need input!'
			end
			code[value_arr[0]] = (amp ? amp.shift : gets.chomp.to_i)
		when 4
			return_value = value_arr[0]
			return [return_value, start]
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

	# code
	return_value
end

# It took me so long to understand...
def find_highest_thrust2
	max = nil

	[5, 6, 7, 8, 9].permutation.each do |permu|
		keep_looping = true
		loop_count = 0
		amp_idx = { 0 => 0,
							1 => 0,
							2 => 0,
							3 => 0,
							4 => 0 }
		output = 0
		arr = []
		5.times { arr.push(get_input('input.txt', true)) }
		while (keep_looping)
			arr.each_with_index do |amp, i|
				input = (loop_count.zero? ? [permu[i], output] : [output])
				output_and_idx = parse_code(amp, input, amp_idx[i])
				if output_and_idx.nil?
					keep_looping = false
					break
				else
					output = output_and_idx[0]
					amp_idx[i] = output_and_idx[1]
				end
			end
			loop_count += 1
		end

		max = output if (max.nil? || output > max)
	end

	max
end

# parse_code(get_input('input.txt', true))
# parse_code(get_input('test2.txt', true))
p find_highest_thrust2

