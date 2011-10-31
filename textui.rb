require_relative 'wordfeud.rb'
require_relative 'solver.rb'

email = # email address of wordfeud account
password = # password

wf = Wordfeud.new
resp = wf.login(email, password)
game = # game id to play

#puts wf.getgames
currentboard = wf.board_array(game)
letters = wf.letters(game)

@sol = Solver.new(currentboard, wf.multiplier_template)
solutions = @sol.solutions(letters, 50)

response = Hash.new
solutions.each{|soltoplay|
  puts "Trying playing: " +  soltoplay["word"] + " for " + soltoplay["points"].to_s + " points."
  response = wf.move(game, wf.solutiontotiles(soltoplay))
  break if response["status"] != "error"
  puts response["content"]["type"]
  }
puts "Played solution " + response["content"]["main_word"].downcase + " for " + response["content"]["points"].to_s + " points."




