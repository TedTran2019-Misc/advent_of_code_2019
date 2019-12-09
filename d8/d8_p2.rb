require 'colorize'

def parse_input(input, file = false)
	file ? File.read(input).chomp : input
end

def create_layers(input, width, height)
	size = width * height # Determine new layer
	layers = []
	i = 0

	# Layer -> Image -> Row
	while i < input.length
		image = []

		height.times do
			image.push(input[i...(width + i)])
			i += width
		end

		layers.push(image)
	end

	layers
end

def create_image(input, width, height)
	layers = create_layers(input, width, height)
	new_image = []
	final_layer_idx = layers.length - 1
	height.times do |y|
		pixel_row = ""
		width.times do |x|
			layers.each_with_index do |current_layer, i|
				pixel = current_layer[y][x]
				if i == final_layer_idx || pixel == '0' || pixel == '1'
					pixel_row << pixel
					break
				end
			end
		end
		new_image << pixel_row
	end
	new_image
end

# Transparent(2) will not be colored (assumed error)
# 0 will be black (invisible on my terminal)
# 1 will be white
def display_image(image)
	image.each do |row|
		row.each_char do |char|
			case char
			when '0'
				print char.colorize(:black)
			when '1'
				print char.colorize(:white)
			when '2'
				print char
			end
		end
		print "\n"
	end
end

display_image(create_image(parse_input('input.txt', true), 25, 6))
# display_image(create_image('0222112222120000', 2, 2))
