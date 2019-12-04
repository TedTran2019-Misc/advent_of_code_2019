# 6 digits
# Between 357253 and 892942
# At least two adjacent digits are the same
# Numbers never decrease, only increase or stay the same
# Above is for first part of question

# Second question has revised rules
#

def check_valid(nbr)
	nbr = nbr.to_s
	adjacent = 0
	(0...(nbr.length - 1)).each do |idx|
		return false if nbr[idx] > nbr[idx + 1]
		adjacent += 1 if nbr[idx] == nbr[idx + 1]
	end
	adjacent > 0
end

# Only a single double adjacent counts
def check_valid2(nbr)
	nbr = nbr.to_s
	adjacent = 0
	(0...(nbr.length - 1)).each do |idx|
		return false if nbr[idx] > nbr[idx + 1]
		adjacent += 1 if nbr[idx] == nbr[idx + 1] &&
										 nbr[idx - 1] != nbr[idx] &&
										 nbr[idx + 2] != nbr[idx]
	end
	adjacent > 0
end

def possibilities_within_range(start, final)
	(start..final).inject(0) { |accu, nbr| check_valid2(nbr) ? accu + 1 : accu }
end

puts check_valid(111111)
puts check_valid(223450)
puts check_valid(123789)

puts possibilities_within_range(357253, 892942)
