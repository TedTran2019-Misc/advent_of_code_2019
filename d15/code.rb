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
