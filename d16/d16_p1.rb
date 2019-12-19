class FFT
	attr_reader :input, :pattern

	def initialize(input, pattern)
		@input = input.split('').map(&:to_i)
		@pattern = pattern.split(', ').map(&:to_i)
	end

	def fft(phases)
		phases.times { clean_signal }
	end

	def clean_signal
		new_input = []
		(1..(@input.length)).each do |output_pos|
			signal_pattern = pattern_for_signal(output_pos)
			new_input << apply_pattern(signal_pattern)
		end
		@input = new_input
	end

	def	apply_pattern(signal_pattern)
		signal_pattern.map!.with_index { |nbr, idx| @input[idx] * nbr }
		signal_pattern.sum.to_s[-1].to_i
	end

	def pattern_for_signal(output_pos)
		signal_pattern = []
		first = true

		until signal_pattern.length >= @input.length
			@pattern.each do |nbr|
				numbers = [nbr] * output_pos
				if first
					first = false
					signal_pattern.concat(numbers[1..-1])
				else
						signal_pattern.concat(numbers)
				end

				break if signal_pattern.length >= @input.length
			end
		end

		signal_pattern.take(@input.length)
	end
end

test_input = '12345678'
test_pattern = '0, 1, 0, -1'
input = File.read('input.txt')
pattern = '0, 1, 0, -1'
a = FFT.new(input, pattern)
# (1..8).each { |i| p a.pattern_for_signal(i) }
a.fft(100)
p a.input.take(8)
