def add(input)
  return 0 if input == ""

  numbers = if input[0][ /[0-9]/]
    input.gsub("\n", ",").split(",")
  else
    input.gsub("\n", input[0]).split(input[0])
  end

  numbers.map(&:to_i).reduce(:+)
end
