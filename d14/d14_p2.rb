# Goes down to deepest level with 1 trillion ore
# Binary search with differing amounts of ores
def minimum_ore_for_reaction(dicts, goal)
	ore_dict, reaction_dict = dicts
	ore_required = 0
	goal_name = goal[1]
	goal_number = goal[0]

	return 0 if ore_dict[goal_name] >= goal_number

	if goal_name == 'ORE'
		ore_required += goal_number
		ore_dict[goal_name] += goal_number
	else
		# This is the hard part for the adjustment-- how do you deal with leftovers?
		# Minimum guess needed to obtain necessary materials?
		num_created = reaction_dict[goal_name][0]
		reaction_dict[goal_name][1..-1].each do |requirement|
			input_nbr = requirement[0]
			input_name = requirement[1]
			until ore_dict[input_name] >= input_nbr
				ore_required += minimum_ore_for_reaction(dicts, requirement)
			end
			ore_dict[input_name] -= input_nbr
		end
		ore_dict[goal_name] += num_created
	end

	until ore_dict[goal_name] >= goal_number
		ore_required += minimum_ore_for_reaction(dicts, goal)
	end

	ore_required
end

def number(str)
	str.to_i
end

def name(str)
	i = str.index(/\D/)
	str[i..-1]
end

# Ore dict to keep track of amount of each ore
# Output dict- output material : [amount created, [number needed, chem needed], etc]
def create_ore_and_reaction_dicts(input, file = false)
	if file
		input = File.read(input)
	end

	ore_dict = Hash.new
	reaction_dict = Hash.new

	input.each_line do |reaction|
		output_start = reaction.index('>') + 1
		output = reaction[output_start..-1].gsub(/\s+/, "")
		input = reaction[0...(output_start - 2)].gsub(/\s+/, "")
		input = input.split(',').map { |ore| [number(ore), name(ore)]}
		ore_dict[name(output)] = 0
		reaction_dict[name(output)] = [number(output)] + input
	end

	ore_dict['ORE'] = 0
	[ore_dict, reaction_dict]
end

a = create_ore_and_reaction_dicts('input.txt', true)
b = create_ore_and_reaction_dicts('157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT')
c = create_ore_and_reaction_dicts('2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF')
d = create_ore_and_reaction_dicts('171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX')

p minimum_ore_for_reaction(b, [50000, 'FUEL'])
