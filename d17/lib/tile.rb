class Tile
	attr_accessor :type, :intersection, :nbr_visits

	def initialize(type)
		@type = type
		@visited = false
		@intersection = false
		@nbr_visits = 0
	end

	def visited?
		@visited
	end

	def mark_visited
		@visited = true
		@nbr_visits += 1
	end

	def mark_unvisited
		@visited = false
		@nbr_visits -= 1
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
