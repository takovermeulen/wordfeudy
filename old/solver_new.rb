require 'rubygems'
board = [[["t",false],["e",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["x",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["q",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["z",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["t",false],["e",false],["",false],["",false],["",false],["",false],["",false],["h",false],["a",false],["n",false],["g",false],["e",false],["n",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]]]

multiplier = [[['TW'], [''], [''], ['DL'], [''], [''], [''], ['TW'], [''], [''], [''], ['DL'], [''], [''], ['TW']], 
[[''], ['DW'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['DW'], ['']], 
[[''], [''], ['DW'], [''], [''], [''], ['DL'], [''], ['DL'], [''], [''], [''], ['DW'], [''], ['']], 
[['DL'], [''], [''], ['DW'], [''], [''], [''], ['DL'], [''], [''], [''], ['DW'], [''], [''], ['DL']], 
[[''], [''], [''], [''], ['DW'], [''], [''], [''], [''], [''], ['DW'], [''], [''], [''], ['']], 
[[''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], ['']], 
[[''], [''], ['DL'], [''], [''], [''], ['DL'], [''], ['DL'], [''], [''], [''], ['DL'], [''], ['']], 
[[''], ['', ''], [''], ['', ''], [''], [''], [''], [''], [''], [''], [''], [''], [''], [''], ['']], 
[[''], [''], ['DL'], [''], [''], [''], ['DL'], [''], ['DL'], [''], [''], [''], ['DL'], [''], ['']], 
[[''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], ['']], 
[[''], [''], [''], [''], ['DW'], [''], [''], [''], [''], [''], ['DW'], [''], [''], [''], ['']], 
[['DL'], [''], [''], ['DW'], [''], [''], [''], ['DL'], [''], [''], [''], ['DW'], [''], [''], ['DL']], 
[[''], [''], ['DW'], [''], [''], [''], ['DL'], [''], ['DL'], [''], [''], [''], ['DW'], [''], ['']], 
[[''], ['DW'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['DW'], ['']], 
[['TW'], [''], [''], ['DL'], [''], [''], [''], ['TW'], [''], [''], [''], ['DL'], [''], [''], ['TW']]]

class Solver
  attr_accessor :wordlist, :board, :multiplier_template

  def initialize(board, multiplier_template)
    @multiplier_template = multiplier_template
    @board = board
    @wordlist = Array.new
    File.open("dict.txt", "r") do |infile|
        while (word = infile.gets)
          @wordlist << word.downcase.chomp
        end
    end
  end
  def getrow(row)
      @board[row - 1].map{|char| char[0]}
  end
  def getcol(col)
    @board.transpose[col - 1].map{|char| char[0]}
  end
  def findperms(letters, roworcol, direction)
    letters = letters.downcase.split(//)
    wordlist = Array.new
    case direction
    when :horizontal
      characters = getrow(roworcol)
    when :vertical
      characters = getcol(roworcol)
    end

    for position in 0..13
      for length in 2..15-position
        #check if characters on board for this sequence
        next if characters[position..position+length-1].join.length == 0

        #check if place before word is empty or out of board
        unless (position - 1) < 0
          next if characters[position-1] != ""
        end

        #check if place after word is empty or out of board
        unless position+length > 14
          next if characters[position+length] != ""
        end
        #check if enough letters available
        next if characters[position..position+length-1].count("") > letters.count
        #check if there are empty places
        next if characters[position..position+length-1].count("") == 0

        #if ok, calc permutations with letters and chars on fixed position
        permutations(letters, characters[position..position+length-1]).each do |solution|
          case direction
          when :horizontal
            x = position + 1
            y = roworcol
              wordlist << {"word"=> solution, "x"=> x, "y" => y, "direction" => :horizontal}
          when :vertical
            x = roworcol
            y = position + 1
              wordlist << {"word" => solution, "x" => x, "y" => y, "direction" => :vertical}
          end
        end
      end
    end

    # check if words in dictionary -> move to final loop
    # make solutions unique
    wordlist.uniq!
    matchedwords = wordlist.map {|solution| solution["word"]}
    matchedwords.uniq!
    matchedwords = checkwords(matchedwords)
    wordlist.delete_if {|solution| matchedwords.include?(solution["word"]) == false}
    wordlist.delete_if {|solution|
      checkaroundsolution(solution["x"],solution["y"],solution["direction"], solution["word"]) == false
    }
    return wordlist
  end


  def checkaroundsolution(x, y, direction, solution)
    solution = solution.split(//)

    case direction
    when :horizontal
      charsonboard = getrow(y)[x-1..x-1+solution.count-1]
      charsonboard.each_index do |letterindex|
        if charsonboard[letterindex] == ""
          # check if word in other direction is ok
          chars = getcol(x+letterindex)
          chars[y-1] = solution[letterindex]
          word = findword(chars, y-1)
          if word.length > 1
            return false if @wordlist.include?(word) == false
          end
        end
      end
      return true
    when :vertical
    end

  end
  def findword(chars, index)
    chars.map! {|char|
      if char == ""
        " "
      else
        char = char
      end}
    foundword = String.new
    words = chars.join.split(' ')
    words.each {|word|
      if index >= chars.join.index(word)
        if index <= (chars.join.index(word) + (word.length-1))
          foundword = word
        end
      end
      }
    return foundword

  end
  def checkwords(wordsasarray)
    return wordsasarray & @wordlist
  end
  def permutations(letters = ["a", "b", "c"], format = ["a","","","s",""])

    permutations = letters.permutation(format.count("")).to_a
    permutations.each_index do |index|
      solution = Array.new
      format.each do |letter|
        if letter == ""
          solution << permutations[index].first
          permutations[index].delete_at(0)
        else
          solution << letter
        end
      end
      permutations[index] = solution.join
    end
    return permutations

  end
  def findsolutions
    solutions = Array.new
    for i in 1..15
        solutions += findperms("test", i, :horizontal)
    end
    return solutions
  end
  def test(letters, format)
    #build regex
    requiredregex = ""
    format.each do |char|
      if char != ""
        requiredregex = requiredregex + char
      else
        requiredregex = requiredregex + "[" + letters + "]?"
      end
    end
    requiredregex = Regexp.new("^" + requiredregex + "$")
    
    #find solutions
    solutions = Array.new
    @wordlist.each {|word| solutions << word if word =~ requiredregex}
    
    #remove solutions with too much letters
    solutions.select!{|solution| 
      ok = true
      letters.split(//).each {|letter| ok = false if (solution.count(letter) - format.count(letter)) > letters.count(letter)}
      ok }
        
    return solutions
  end
end

sol = Solver.new(board,multiplier)
puts sol.test("st", ["t","e","","",""])