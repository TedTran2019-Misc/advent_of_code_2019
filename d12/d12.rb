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
a.moon_motion(1000)
p a.total_energy
