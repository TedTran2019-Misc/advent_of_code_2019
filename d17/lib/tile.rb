class Tile
	attr_accessor :type, :intersection

	def initialize(type)
		@type = type
		@visited = false
		@intersection = false
	end

	def visited?
		@visited
	end

	def mark_visited
		@visited = true
	end

	def mark_unvisited
		@visited = false
	end

	def to_s
		@type
	end

	def inspect
		@type
	end

	def set_intersection
		@intersection = true
	end

	def intersection?
		@intersection
	end
end
