require_relative 'wordfeud.rb'
require_relative 'solver.rb'

wf = Wordfeud.new

#puts wf.getgames
currentboard = [[["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["h", false], ["e", false], ["k", false], ["j", false], ["e", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["a", false], ["", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["l", false], ["", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["i", false], ["", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["s", false], ["m", false], ["e", false], ["r", false], ["e", false], ["n", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["a", false], ["", false], ["", false], ["f", false], ["", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["n", false], ["", false], ["", false], ["", false], ["j", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["d", false], ["o", false], ["o", false], ["d", false], ["s", false], ["e", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["u", false], ["", false], ["", false], ["a", false], ["u", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["z", false], ["o", false], ["n", false], ["k", false], ["", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["", false], ["e", false], ["n", false], ["t", false], ["t", false], ["e", false], ["", false], ["", false]], [["", false], ["", false], ["", false], ["", false], ["r", false], ["a", false], ["i", false], ["o", false], ["s", false], ["", false], ["e", false], ["", false], ["", false], ["", false], ["", false]]]
letters = "dgdnbra"

@sol = Solver.new(currentboard, wf.multiplier_template)
#solutions = @sol.solutions(letters, 50)

puts @sol.getmatches(["", "","", "s","","","d","e","","","f","s","","a",""], "abc")
#puts @sol.getmatches(["", "",""], "abc")





