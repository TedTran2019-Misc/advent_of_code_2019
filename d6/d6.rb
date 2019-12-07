class Node
	attr_reader :parent, :children, :value
	attr_accessor :children_count

	def initialize(value)
		@parent = nil
		@children = []
		@value = value
		@children_count = 0 # Set by dfs_set_children_count
	end

	def parent=(parent_node)
		raise 'Nope!' if parent_node == self ||
									@children.include?(parent_node) ||
									!parent_node.is_a?(Node)

		@parent.remove_child(self) unless @parent.nil?
		@parent = parent_node
		parent_node.children.push(self)
	end

	def child=(child)
		child.parent = self
	end

	def remove_child(child)
		child_idx = @children.index(child)
		return child_idx if child_idx.nil?

		@children[child_idx].parent = nil
		@children.delete_at(child_idx)
	end

	def inspect
		"#{@value} : #{@children.length} children"
	end

	def return_top_node
		current = self
		current = current.parent until current.parent.nil?
		current
	end

	def dfs_set_children_count
		if @children.empty?
			@children_count = 0
			return @children_count
		end

		total = 0
		@children.each { |child| total += child.dfs_set_children_count }
		@children_count = total + @children.length
	end

	def count_children
		return @children_count if @children.empty?

		total = 0
		@children.each { |child| total += child.count_children }
		return total + @children_count
	end

	def count_steps_between(finish_node)
		return self if self == finish_node


	end
end

# a = Node.new
# b = Node.new
# a.parent = a
# a.child = b
# a.parent = b
# a.parent = [1, 2, 3]

def parse_data(filename)
	node_dict = Hash.new
	File.foreach(filename).each do |line|
		orbits = line.chomp.split(')')
		orbits.each { |orbit| node_dict[orbit] ||= Node.new(orbit) }
		parent = orbits[0]
		child = orbits[1]
		node_dict[parent].child = node_dict[child]
	end
	node_dict
end

def count_all_orbits(input)
	top_node = parse_data(input).values[0].return_top_node
	top_node.dfs_set_children_count
	top_node.count_children
end

def count_orbital_transfer_between(input, start, finish)
	node_dict = parse_data(input)
	start_node = node_dict[start].parent
	finish_node = node_dict[finish].parent

	start_node.count_steps_between(finish_node)
end

# p count_all_orbits('input.txt')
# p count_all_orbits('test.txt')
p count_orbital_transfer_between('test2.txt', 'YOU', 'SAN')

