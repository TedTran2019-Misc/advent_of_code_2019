# Looking at vinc's solution and thinking about the logic
# This is word for word vinc's solution.
# Abstract into classes-- better readability.
=begin
His approach to the problem:
- wasted and needed dictionaries that start at 0
- Grab how much is made and what makes it
- Has a mult so 1 fuel and lots of fuel can be calculated easily
	- ((quantity wanted - wasted) / quantity_made).ceil (I also did this in my solution
		but to no avail.)
- If wasted is more than quantity, wasted -= quantity
- Otherwise, needed minus wasted to use as much as possible
- Calculate amount wasted remaining (mult * amount_made - needed)
- For each input, make a needed
	- Set to 0 if there's nothing there, then add mult * amount input needed
	- Call cost again unless it's ORE, but changing quantity into mult * quantity
	- At the end, set needed to zero and show needed["ORE"]

- Why did my original solution fail for d14 p2?
	- Confusion due to bad names (poor abstraction)
	- Nearly impossible and solve problems when code is confusing and difficult to understand.
	- I did the "mult", named guess in mine, inside of the loop causing different
		multiples for each.
	- Didn't think about the problem before attempting to solve it. In a recursive
		problem, consider the base case(smallest subproblem) and the top case...
=end
class Chemical
	attr_reader :quantity, :name

	def initialize(chemical)
		quantity, name = chemical.split
		@quantity = quantity.to_i
		@name = name
	end
end

class Reaction
	attr_reader :inputs, :output

	def initialize(reaction)
		inputs, output = reaction.split(' => ')
		@inputs = inputs.split(', ').map { |input| Chemical.new(input) }
		@output = Chemical.new(output)
	end
end

class Nanofactory
	attr_reader :reactions

	def initialize(str)
		@reactions = {}
		str.each_line do |line|
			reaction = Reaction.new(line)
			@reactions[reaction.output.name] = [reaction.output.quantity, reaction.inputs]
		end
	end

	def cost(quantity, name, needed = {}, wasted = {})
    wasted[name] ||= 0
    needed[name] ||= 0
    reaction_quantity, inputs = @reactions[name]
    mult = [((quantity - wasted[name]) / reaction_quantity.to_f).ceil, 0].max
    if quantity < wasted[name]
      wasted[name] -= quantity
    else
      needed[name] -= wasted[name]
      wasted[name] = mult * reaction_quantity - needed[name] if name != "FUEL"
      inputs.each do |input|
        needed[input.name] ||= 0
        needed[input.name] += mult * input.quantity
        cost(input.quantity * mult, input.name, needed, wasted) if input.name != "ORE"
      end
    end
    needed[name] = 0
    needed["ORE"]
	end
end

a = File.read('input.txt')
p Nanofactory.new(a).cost(1, 'FUEL')
