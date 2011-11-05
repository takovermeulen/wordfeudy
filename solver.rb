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
    characters = getline(line, direction)
    puts getmatches(characters)
    # check where solution fits
    
    # get newchars
    
    # check words in other direction
    
    return solutions
  end
  
  def buildregex(characters, letters)
    regex = ""
    # build regex
    regexarr = Array.new
    matches = Array.new
    characters.each_index {|i| characters[i] = " " if characters[i].empty?}
    characters = characters.join.scan(/[a-z]*/)[0..-2]
    characters.each_index {|i| matches << [characters[i], i] if !characters[i].empty? }
    newmatches = Array.new
    matches.each_index {|i| 
      if i == (matches.count - 1) and i == 0
       newmatches[i] = [matches[i][1], matches[i][0], (characters.count - matches[i][1]) - 1]
      elsif i == 0
        newmatches[i] = [matches[i][1], matches[i][0], (matches[i+1][1] - matches[i][1]) -1]
      elsif i == (matches.count - 1)
        newmatches[i] = [(matches[i][1] - matches[i-1][1]) - 1, matches[i][0], (characters.count - matches[i][1]) - 1]
      else
        newmatches[i] = [(matches[i][1] - matches[i-1][1]) - 1, matches[i][0], (matches[i+1][1] - matches[i][1]) - 1]
      end
      }
    matches = newmatches
    for i in 0..(matches.count - 1)
      if i == (matches.count - 1) and i == 0
        regexarr << ".\{0," + matches[i][0].to_s + "\}" + matches[i][1] + ".\{0," + (matches[i][2]).to_s + "\}"
      elsif i == 0
        regexarr << ".\{0," + matches[i][0].to_s + "\}" + matches[i][1] + ".\{0," + (matches[i][2] - 1).to_s + "\}"
      elsif i == (matches.count - 1)
        regexarr << ".\{0," + (matches[i][0] -1 ).to_s + "\}" + matches[i][1] + ".\{0," + (matches[i][2]).to_s + "\}"
      else
        regexarr << ".\{0," + (matches[i][0] - 1).to_s + "\}" + matches[i][1] + ".\{0," + (matches[i][2] - 1).to_s + "\}"
      end
    end
    
    return matches
    #return regex
  end
  
  def getmatches(characters, letters)
    matches = Array.new
    
    puts buildregex(characters, letters).to_s
    
    #requiredregex = Regexp.new("^" + regex.join + "$")

    #find solutions  
    #solutions = @wordlist.grep(requiredregex)
       
    #check length of solution
    #solutions.select!{|solution| solution.length < 16}

    #remove solutions with too much letters
    #solutions.select!{|solution| 
    #  ok = true
    #  letters.split(//).uniq.each {|letter| ok = false if (solution.count(letter) - letters.count(letter)) > letters.count(letter)}
    #  ok }

    #return solutions.uniq    
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