# pixels wide -> x
# pixels tall -> y
# Each layer has x by y pixels

def parse_input(input, file = false)
	file ? File.read(input).chomp : input
end

# On layer with least zeroes, what is # of 1 digits multiplied by # of 2 digits?
def count_digits(input, size)
	layer_digits = []
	layer = -1

	input.each_char.with_index do |char, i|
		if (i % size).zero?
			layer_digits.push(Hash.new(0))
			layer += 1
		end

		layer_digits[layer][char] += 1
	end

	least_zeroes = layer_digits.min { |a_hash, b_hash| a_hash['0'] <=> b_hash['0'] }
	least_zeroes['1'] * least_zeroes['2']
end


p count_digits(parse_input('input.txt', true), 25 * 6)

