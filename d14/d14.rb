# Didn't account for multiple things, resulting in an error.
# How about... one ore dict storing amount of every single ore
# One dict from output : input
# - [name(output)] = [number(output)], [nbr, name], [nbr, name], [nbr, name]


# Change the logic on this and how you intend to do it
def minimum_ore_for_reaction(dicts, goal)
	ore_dict, reaction_dict, input_dict = dicts
	ore_required = 0

	if name(goal) == 'ORE'
		ore_required += number(goal)
		output = input_dict[goal] # This won't work because ORE makes multiple thingsls

		ore_dict[name(output)] += number(output)
	else
		reaction_dict[goal].split(',').each do |requirement|
			next if ore_dict[name(requirement)] >= number(requirement)
			ore_required += minimum_ore_for_reaction(dicts, requirement)
		end
	end

	until reaction_accomplished(reaction_dict[goal], ore_dict)
		ore_required += minimum_ore_for_reaction(dicts, requirement)
	end

	ore_required
end

# Fix this after the dicts are changed and fixed
def reaction_accomplished(requirements, ore_dict)
	return true if requirements.nil?
	requirements.all? do |requirement|
		ore_dict[name(requirement)] >= number(requirement)
	end
end

def number(str)
	str.to_i
end

def name(str)
	i = str.index(/\D/)
	str[i..-1]
end

# Fix the dicts
def create_ore_and_reaction_dicts(input, file = false)
	if file
		input = File.read(input)
	end

	ore_dict = Hash.new
	reaction_dict = Hash.new
	input_dict = Hash.new

	input.each_line do |reaction|
		output_start = reaction.index('>') + 1
		output = reaction[output_start..-1].gsub(/\s+/, "")
		input = reaction[0...(output_start - 2)].gsub(/\s+/, "")
		ore_dict[name(output)] = 0
		reaction_dict[output] = input
		input_dict[input] = output
	end

	[ore_dict, reaction_dict, input_dict]
end

a = create_ore_and_reaction_dicts('input.txt', true)
b = create_ore_and_reaction_dicts('10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL')
p b
minimum_ore_for_reaction(b, '1FUEL')
