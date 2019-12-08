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
			code[value_arr[0]] = (amp ? amp.shift : gets.chomp.to_i)
		when 4
			return_value = value_arr[0]
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

=begin
p parse_code(get_input('1,0,0,0,99')) == [2,0,0,0,99]
p parse_code(get_input('2,3,0,3,99')) == [2,3,0,6,99]
p parse_code(get_input('2,4,4,5,99,0')) == [2,4,4,5,99,9801]
p parse_code(get_input('1,1,1,4,99,5,6,0,99')) == [30,1,1,4,2,5,6,0,99]
p parse_code(get_input('1002,4,3,4,33')) == [1002,4,3,4,99]

parse_code(get_input('3,9,8,9,10,9,4,9,99,-1,8')) # 1 if input equal to 8, else 0
parse_code(get_input('3,9,7,9,10,9,4,9,99,-1,8')) # 1 if input less than 8, else 0
parse_code(get_input('3,3,1108,-1,8,3,4,3,99')) # 1 if input equal to 8, else 0
parse_code(get_input('3,3,1107,-1,8,3,4,3,99')) # 1 if input less than 8, else 0

parse_code(get_input('3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9')) # 0 if input 0, else 1
parse_code(get_input('3,3,1105,-1,9,1101,0,0,12,4,12,99,1')) # 0 if input 0, else 1

# 999 if below 8, 1000 if equals 8, 1001 if greater than 5
parse_code(get_input('3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99'))

# 1 for silver, 5 for gold as inputs
parse_code(get_input('input.txt', true))
=end

# Part 1
def find_highest_thrust
	max = nil
	max_permu = nil

	[0, 1, 2, 3, 4].permutation.each do |permu|
		output = 0
		permu.each do |ele|
			output = parse_code(get_input('input.txt', true), [ele, output])
		end

		if (max.nil? || output > max)
			max = output
			max_permu = permu
		end
	end

	p max_permu
	p max
end

find_highest_thrust # [2, 0, 1, 4, 3], 101490
# parse_code(get_input('input.txt', true))
# parse_code(get_input('test2.txt', true))
