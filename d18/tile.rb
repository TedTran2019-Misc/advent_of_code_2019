class Tile
	attr_accessor :type
	attr_reader :visited

	def initialize(type)
		@type = type
		@visited = false
	end

	def mark_visited
		@visited = true
	end

	def unmark_visited
		@visited = false
	end

	def to_s
		@type
	end

	def inspect
		@type
	end
end
