require 'rubygems'

class Solver
  attr_accessor :wordlist, :board, :multiplier_template

  def initialize(board, multiplier_template)
    @scores = {"nl" => {'a' => 1,   'g' => 3,   'm' => 3,   's' => 2,   'y' => 8,
    'b' => 3,   'h' => 4,   'n' => 1,    't' => 2,
    'c' => 5,   'i' => 1,   'o' => 1,   'u' => 4,   'z' => 4,
    'd' => 2,   'j' => 4,   'p' => 3,   'v' => 4,   
    'e' => 1,    'k' => 3,   'q' => '10',   'w' => 5,       
    'f' => 4,   'l' => 3,   'r' => 2,   'x' => 8}}
    @multiplier_template = multiplier_template
    @board = board
    @wordlist = Array.new
    File.open("dict.txt", "rb") do |infile|
        while (word = infile.gets)
          @wordlist << word.downcase.chomp
        end
    end
    # remove words with non-letter characters or upper case characters from dictionary
    @wordlist.delete_if {|word| word =~ /[^a-z]/}
  end
  
  def getline(number, direction, board = @board)
      case direction
      when :horizontal
        return board[number - 1].map{|char| char[0]}
      when :vertical
        return board.transpose[number - 1].map{|char| char[0]}
      end
  end

  def findboardsolutions(letters, line, direction)

    wordlist = Array.new
    characters = getline(line, direction)
    
    # skip line if it has no chars
    unless characters.count("") == 15
    
    for position in 0..13
        
      for length in 2..15-position
        #check if characters on board for this sequence
        
        next if characters[position..position+length-1].count("") == length
        
        #check if place before word is empty or out of board
        unless (position - 1) < 0
          next if characters[position-1] != ""
        end

        #check if place after word is empty or out of board
        unless position+length > 14
          next if characters[position+length] != ""
        end
        #check if enough letters available
        next if characters[position..position+length-1].count("") > letters.length
        #check if there are empty places
        next if characters[position..position+length-1].count("") == 0
        
        #if ok, calc permutations with letters and chars on fixed position
        findsolutions(letters, characters[position..position+length-1]).each do |solution|
          #get newchars
          newchars = Array.new 
          solution.split(//).each_index{|index|
            unless solution.split(//)[index] == characters[position..position+length-1][index]
              newchars << {"letter" => solution.split(//)[index], "index" => index} 
            end
            }
            
          case direction
          when :horizontal
            x = position + 1
            y = line

              wordlist << {"word"=> solution, "x"=> x, "y" => y, "direction" => :horizontal, "newchars" => newchars}
          when :vertical
            x = line
            y = position + 1
              wordlist << {"word" => solution, "x" => x, "y" => y, "direction" => :vertical, "newchars" => newchars}
          end
        end
      end
    end
    end

    
    # make solutions unique and check related words
    wordlist.uniq!
    wordlist.each {|solution| solution["relatedwords"] = findwordsinsolution(solution)}
    wordlist.select! {|solution| 
      solution["relatedwords"].map {|word| word["in_dictionary"]}.count(false) == 0
      }
    
    
    # get score
    wordlist.each{|solution|
      points = 0
      
      #get score of solution word
      points += calcpoints(solution)
      
      #get score of other words
      solution["relatedwords"].each{|solution_word|

          points += calcpoints(solution_word)
       }
      solution["points"] = points
      
    }
    return wordlist
  end
  
  def calcpoints(solution)
    points = 0
    multiplier = 1
    solution["word"].split(//).each {|char|
      points += @scores["nl"][char]
      }

    solution["newchars"].each {|newchar|
      x = 0
      y = 0
      case solution["direction"]
        when :horizontal
          x = newchar["index"] + solution["x"]
          y = solution["y"]
        when :vertical
          x = solution["x"]
          y = newchar["index"] + solution["y"]
      end

      case @multiplier_template[x-1][y-1][0]
        when "DL"
          points += @scores["nl"][newchar["letter"]]
        when "TL"
          points += 2 * @scores["nl"][newchar["letter"]]
        when "DW"
          multiplier = multiplier * 2
        when "TW"
          multiplier = multiplier * 3
      end
    }
    return points*multiplier
  end

  def findwordsinsolution(solution)
    words = Array.new
    x = solution["x"]
    y = solution["y"]
    direction = solution["direction"]
    word = solution["word"].split(//)
    newchars = solution["newchars"]
    case direction
    when :horizontal
      board = @board
      x = solution["x"]
      y = solution["y"]
    when :vertical
      board = @board.transpose
      y = solution["x"]
      x = solution["y"]
    end
    
    newchars.each do |newchar|
      # check if word in other direction is ok
      chars = getline(x+newchar["index"], :vertical, board)
      chars[y-1] = newchar["letter"]
      newword = findword(chars, y-1)
      if newword["word"].length > 1
        foundword = Hash.new
        foundword["word"] = newword["word"]
        foundword["in_dictionary"] =  @wordlist.include?(newword["word"])
        foundword["newchars"] = [{"index" => (y-1) - newword["start_index"], "letter" => newchar["letter"]}]
        case direction
          when :horizontal
            foundword["x"] = x+newchar["index"]
            foundword["y"] = newword["start_index"] + 1
            foundword["direction"] = :vertical
          when :vertical
            foundword["y"] = x+newchar["index"]
            foundword["x"] = newword["start_index"] + 1
            foundword["direction"] = :horizontal  
          end 
        words << foundword
      end
    end
      
    # returns a) all words in other directions for each new char, b) x and y for the start of word, c) direction and 
    # d) index of new letter and e) whether those words are in the dict
    

    return words

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
    return {"word" => foundword, "start_index" => chars.join.index(foundword)}

  end

  def findsolutions(letters, format)
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
    solutions = @wordlist.grep(requiredregex)
    # check length of solution
    solutions.select!{|solution| solution.length == format.count}
    #remove solutions with too much letters
    solutions.select!{|solution| 
      ok = true
      letters.split(//).each {|letter| ok = false if (solution.count(letter) - format.count(letter)) > letters.count(letter)}

      ok }
        
    return solutions
  end
  def solutions(letters, numberofsolutions = 20)
    solutions = Array.new
    for row in 1..15
      solutions += findboardsolutions(letters,row, :horizontal)
    end
    for col in 1..15
      solutions += findboardsolutions(letters,col, :vertical)
    end
    return solutions.sort_by{|solution| solution["points"]}.reverse[0..numberofsolutions-1]
  end
end