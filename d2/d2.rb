def get_input(input, filename = false)
	if filename
		File.foreach(input) { |line| return line.chomp.split(',').map { |char| char.to_i } }
	else
		return input.split(',').map { |char| char.to_i }
	end
end

def parse_code(code)
	start = 0

	while (start <= code.length - 4)
		case code[start]
		when 99
			break
		when 1..2
			first_num_idx = code[start + 1]
			second_num_idx = code[start + 2]
			finish_idx = code[start + 3]
			f_num = code[first_num_idx]
			s_num = code[second_num_idx]
			code[finish_idx] = (code[start] == 1 ? (f_num + s_num) : (f_num * s_num))
		else
			raise 'Unknown opcode!'
		end
		start += 4
	end

	code
end

p parse_code(get_input('input.txt', true))
p parse_code(get_input('1,0,0,0,99'))
p parse_code(get_input('2,3,0,3,99'))
p parse_code(get_input('2,4,4,5,99,0'))
p parse_code(get_input('1,1,1,4,99,5,6,0,99'))

def updated_input(filename, noun, verb)
	input = get_input(filename, true)
	input[1] = noun
	input[2] = verb
	input
end

def bruteforce(output)
	(0..99).each do |noun|
		(0..99).each do |verb|
			if parse_code(updated_input('input.txt', noun, verb))[0] == output
				return [noun, verb]
			end
		end
	end
end

p bruteforce(19690720)
