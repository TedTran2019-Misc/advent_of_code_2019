class Tile
	attr_accessor :type, :intersection
	attr_reader :visited

	def initialize(type)
		@type = type
		@visited = false
		@intersection = false
	end

	def visited
		@visited = true
	end

	def unvisited
		@visited = false
	end

	def to_s
		@type
	end

	def inspect
		@type
	end

	def is_intersection
		@intersection = true
	end
end
