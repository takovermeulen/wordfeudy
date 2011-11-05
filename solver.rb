require 'rubygems'

class Solver
  attr_accessor :wordlist, :custom_wordlist, :board, :multiplier_template

  def initialize(board, multiplier_template)
    @scores = {"nl" => {'a' => 1,   'g' => 3,   'm' => 3,   's' => 2,   'y' => 8, '?' => 0,
    'b' => 4,   'h' => 4,   'n' => 1,    't' => 2,
    'c' => 5,   'i' => 2,   'o' => 1,   'u' => 2,   'z' => 5,
    'd' => 2,   'j' => 4,   'p' => 4,   'v' => 4,   
    'e' => 1,    'k' => 3,   'q' => 10,   'w' => 5,       
    'f' => 4,   'l' => 3,   'r' => 2,   'x' => 8}}
    @multiplier_template = multiplier_template
    @board = board
    
    #read custom dict with valid board words
    @custom_wordlist = File.open("custom_dict.txt", "rb") {|f| f.read}.split("\n").map {|word| word.chomp.downcase}
 
    # read board and add to custom dictionary if it contains new words 
    File.open("custom_dict.txt", 'a') {|f| f.puts(findboardwords - @custom_wordlist)}
     
    # read dictionary (already a clean lowercase file)
    @wordlist = File.open("dict.txt", "rb") {|f| f.read}.split("\n")
  end
  
  def findboardwords(lines = (1..15).to_a, directions = [:horizontal, :vertical])
    words = Array.new
    directions.each{|dir| 
      case dir
      when :horizontal
      lines.each{|line|
        wordsinline = @board[line - 1].map{|char| if char[0].empty? then " " else char[0] end}.join.split(" ")
        wordsinline.each{|word| words << word.downcase if word.length > 1}
        }
      when :vertical
        lines.each{|line|
          wordsinline = @board.transpose[line - 1].map{|char| if char[0].empty? then " " else char[0] end}.join.split(" ")
          wordsinline.each{|word| words << word.downcase if word.length > 1}
        }
      end
    }
    return words
  end
  
  def checkwords(words)
    if ((@wordlist + @custom_wordlist) & words).count == words.count
      return true
    else
      return false
    end
  end
  
  def getline(line, direction)
    case direction
      when :horizontal
        charsinline = @board[line -1 ].map{|char| char[0]}
      when :vertical
        charsinline = @board.transpose[line - 1].map{|char| char[0]}
    end
    return charsinline
  end

  def findsolutionsinline(letters, line, direction)
    print "Finding solutions in line " + line.to_s + ", direction " + direction.to_s + ". "
    solutions = Array.new
    matches = getmatches(getline(line, direction))
    # check where solution fits
    
    # get newchars
    
    # check words in other direction
    
    return solutions
  end
  
  
  def getmatches(characters, letters)
    letters = letters.split(//)
    matches = Array.new
    permutations = Hash.new
    characters.each_index{|i| characters[i] = " " if characters[i].empty?}
   
    #calc permutations
    for i in 1..letters.count
      permutations[i] = letters.permutation(i).to_a.uniq
    end
    
    #find matches where permutations fit
    for numchars in 2..([letters.count, characters.count(" ")].min)
      permutations[numchars].each { |perm|
        for pos in 0..(characters.count - 1)
          next if characters[pos - 1] != " " unless (pos -1) < 0
          newchars = characters[pos, characters.count]
          j = 0
          newchars.each_index{|i|
            if newchars[i] == " "
              newchars[i] = perm[j] 
              j += 1
            end
            break if perm.count == j
          }
          word = newchars.join.split(/ /).first
          next if j != perm.count
          next if word.length <= perm.count
          matches << {"word" => newchars.join.split(/ /).first, "i" => pos} if (word.length > 1)
        end  
      }
    end
    #find matches in dictionairies
    okmatches = matches.map{|m| m["word"]}.uniq & (@wordlist + @custom_wordlist)
    matches.select! {|m| okmatches.include?(m["word"])}
    
    matches.each {|m|
      newchars = Array.new
      m["word"].split(//).each_index {|i| newchars << {"letter" => m["word"].split(//)[i], "index" => i} unless characters[m["i"] + i] == m["word"].split(//)[i]}
      m["newchars"] = newchars
    }
    return matches
  end

  
  def solutions(letters, numberofsolutions = 20)
    solutions = Array.new
    # horizontal
    (1..15).each {|line| solutions << findsolutionsinline(letters, line, :horizontal)}
    # vertical
    (1..15).each {|line| solutions << findsolutionsinline(letters, line, :vertical)}
    
    # calculate points of solutions
    
    return solutions.sort_by{|solution| solution["points"]}.reverse[0..[numberofsolutions-1, solutions.count].min]
  end
end