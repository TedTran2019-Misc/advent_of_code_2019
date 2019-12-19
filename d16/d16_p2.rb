# First 7 digits is the new offset
# Want first 8 numbers after offset
# Skip everything until offset idx (Don't need)
# After offsetting that much, everything before the offset is zero. (Pattern, *= 0)
# Rest is just 1 since offset is more than double of input (Pattern, *= 1)
class FFT
	attr_reader :input, :pattern

	def initialize(input, pattern)
		@input = input.split('').map(&:to_i)
		@pattern = pattern.split(', ').map(&:to_i)
		@offset = input[0...7].to_i
		@input = @input[@offset..-1] # Discarding initial altogether, offset is 0
	end

	def fft(phases)
		phases.times { clean_signal }
	end

	def clean_signal
		new_input = []
		total = @input.sum
		new_input << total.to_s[-1].to_i
		@input[0...-1].each do |nbr|
			total -= nbr
			new_input << total.to_s[-1].to_i
		end
		@input = new_input
	end
end

# Offset is around 90% of the input
# Everything before offset is unwanted
# Pattern: 0, 1, 0, -1
# Notice starting 0s increases with idx.
# After ignoring first 90% of input, rest of code is just 1.
pattern = '0, 1, 0, -1'

test_input1 = '03036732577212944063491565474664' * 10000
test_input2 = '02935109699940807407585447034323' * 10000
test_input3 = '03081770884921959731165446850517' * 10000

input = File.read('input.txt').chomp * 10000
p input.length
p input[0...7].to_i

a = FFT.new(test_input1, pattern)
b = FFT.new(test_input2, pattern)
c = FFT.new(test_input3, pattern)
z = FFT.new(input, pattern)
a.fft(100)
b.fft(100)
c.fft(100)
z.fft(100)
p a.input.take(8).join
p b.input.take(8).join
p c.input.take(8).join
p z.input.take(8).join
