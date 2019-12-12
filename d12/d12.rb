# Given position of each moon as puzzle input (x, y, z)
# Simulate motion to avoid - simulate in time steps. Moves once all positions updated.
# Update velocity by applying gravity, update position by applying velocity.
# For gravity, consider every pair of moons.
# - If same axis, velocity does not change. If diff, higher -1 lower +1.
# To apply velocity, simply add velocity to the position.
# Total energy in system:
# - single moon is potential energy * kinetic energy
# - potential energy: sum of absolute values of x/y/z coordinates
# - kinetic energy: sum of absolute values of its velocity coordinates

class JupiterDodger
	def initialize(input)
		@input = input
		# Position, Velocity
		@moons_pos = {
			io: [[0, 0, 0], [0, 0, 0]],
			europa: [[0, 0, 0], [0, 0, 0]],
			ganymede: [[0, 0, 0], [0, 0, 0]],
			callisto: [[0, 0, 0], [0, 0, 0]]
		}
		@moons = @moons_pos.keys
		moon_positions(input)
	end

	# Hmm, I'm assuming it's in orbit, so one full cycle === back to original position
	# All the moons are orbiting each other, as well, so they should be cycling
	# Time to take discrete mathematics and number theory.
	# Looking at output -- x-axis of moon cycles landing at the same spot.
	# How long before x-axis of every moon lands at the same spot?
	# How about y-axis of every moon?
	# z-axis of every moon?
	# Don't feel like making a deep dup, will just resend in the input.
	# Least common multiple
	def steps_before_repeat_state
		steps_to_cycle = []
		3.times do |coor| # Index value for coordinate
			steps_to_cycle << JupiterDodger.new(@input).cycle_length(coor)
		end

		steps_to_cycle.inject { |lcm, step| lcm.lcm(step) }
	end

	def cycle_length(coor)
		steps = 0
		orig_pos = @moons_pos.values.map { |value| value[0][coor] }
		orig_vel = @moons_pos.values.map { |value| value[1][coor] }
		while (42)
			apply_gravity_to_velocity
			apply_velocity_to_position
			steps += 1

			break if orig_pos[0] == position(:io)[coor] &&
							 orig_vel[0] == velocity(:io)[coor] &&
							 orig_pos[1] == position(:europa)[coor] &&
							 orig_vel[1] == velocity(:europa)[coor] &&
							 orig_pos[2] == position(:ganymede)[coor] &&
							 orig_vel[2] == velocity(:ganymede)[coor] &&
							 orig_pos[3] == position(:callisto)[coor] &&
							 orig_vel[3] == velocity(:callisto)[coor]
		end
		steps
	end

	# Naive solution(s) won't work here.
	def steps_before_repeat_state_naive
		# state = {}
		steps = 0
		orig = @moons_pos.to_s
		zero_vel = [0, 0, 0]
		starting_time = Time.now
		p @moons_pos
		while (42)
			sleep(1)
			# state.has_key?(@moons_pos.to_s) ? break : state[@moons_pos.to_s] = true

			apply_gravity_to_velocity
			apply_velocity_to_position
			steps += 1
			p @moons_pos
			break if velocity(:io) == zero_vel && @moons_pos.to_s == orig
		end
		steps
	end

	def total_energy
		@moons.inject(0) do |total_energy, moon|
			potential_energy = position(moon).inject(0) { |energy, coor| energy + coor.abs }
			kinetic_energy = velocity(moon).inject(0) { |energy, coor| energy + coor.abs }
			total_energy + (potential_energy * kinetic_energy)
		end
	end

	def moon_motion(steps)
		steps.times do
			apply_gravity_to_velocity
			apply_velocity_to_position
		end
	end

	def position(moon)
		@moons_pos[moon][0]
	end

	def set_position(moon, new_position)
		@moons_pos[moon][0] = new_position
	end

	def velocity(moon)
		@moons_pos[moon][1]
	end

	def set_velocity(moon, new_velocity)
		@moons_pos[moon][1] = new_velocity
	end

	private

	# Gravity has to apply all at once
	def apply_gravity_to_velocity
		gravity_change = gravity_change_hash
		last_idx = @moons.length - 1
		last_idx.times do |x|
			((x + 1)...(@moons.length)).each do |y|
				update_gravity_hash(@moons[x], @moons[y], gravity_change)
			end
		end
		change_gravity(gravity_change)
	end

	def change_gravity(gravity_change)
		@moons.each do |moon|
			x, y, z = velocity(moon)
			dx, dy, dz = gravity_change[moon]
			set_velocity(moon, [x + dx, y + dy, z + dz])
		end
	end

	def update_gravity_hash(moon1, moon2, hash)
		# 0, 1, 2 -> x, y, z
		3.times do |coor|
			coor1 = position(moon1)[coor]
			coor2 = position(moon2)[coor]
			case coor1 <=> coor2
			when 0
				next
			when -1
				hash[moon1][coor] += 1
				hash[moon2][coor] -= 1
			when 1
				hash[moon1][coor] -= 1
				hash[moon2][coor] += 1
			end
		end
	end

	def gravity_change_hash
		hash = {}
		@moons.each { |moon| hash[moon] = Array.new(3, 0) }
		hash
	end

	def apply_velocity_to_position
		@moons.each do |moon|
			x, y, z = position(moon)
			dx, dy, dz = velocity(moon)
			set_position(moon, [x + dx, y + dy, z + dz])
		end
	end

	# Setting the moon [x, y, z] from input.
	def moon_positions(input)
		input = File.read(input) if input.end_with?('.txt')
		input.each_line.with_index do |moon_pos, i|
			moon_coors = moon_pos.chomp.split(',').map do |coor|
				nbr_start = coor.index('=') + 1
				coor[nbr_start..-1].to_i
			end
			current_moon = @moons[i]
			@moons_pos[current_moon][0] = moon_coors
		end
	end
end

a = JupiterDodger.new('input.txt')
=begin
a = JupiterDodger.new('<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>')
a = JupiterDodger.new('<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>')
=end
# a.moon_motion(1000)
# p a.total_energy
# p a.steps_before_repeat_state_naive
p a.steps_before_repeat_state
