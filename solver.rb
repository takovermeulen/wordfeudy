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
    
    #read custom dict with valid board words played earlier and illegal words played earlier
    custom_wordlist = File.open("custom_dict.txt", "rb") {|f| f.read}.split("\n").map {|word| word.chomp.downcase}
    ok_words = custom_wordlist.reject{|word| word[0] != "+"}.map {|word| word[1, word.length]}
    illegal_words = custom_wordlist.reject{|word| word[0] != "-"}.map {|word| word[1, word.length]}
    
    # read dictionary (already a clean lowercase file)
    @wordlist = File.open("dict.txt", "rb") {|f| f.read}.split("\n")   
    
    # read board and add to custom dictionary if it contains new words 
    newwords = findboardwords().uniq
    File.open("custom_dict.txt", 'a') {|f| f.puts((newwords - ok_words - @wordlist).map{|word| "+" + word})}
    
    # add board words and words from custom dictionary to current dictionary and remove any duplicates
    @wordlist += newwords + ok_words - illegal_words
    @wordlist.uniq! 
  end
  
  def findboardwords(lines = (1..15).to_a, directions = [:horizontal, :vertical])
    words = Array.new
    directions.each{|dir| 
      lines.each{|line|
        wordsinline = getline(line, dir, true)
        wordsinline = wordsinline.join.split(" ")
        wordsinline.each{|word| words << word.downcase if word.length > 1}
      }
    }
    return words
  end
  
  def findwordaroundchar(line, direction, index, newchar)
    # get chars in line
    characters = getline(line, direction)
    characters[index] = newchar
    relatedword = Hash.new
    word = ""
    
    # search for word
    (index - 1).downto(0) { |i|
      break if characters[i].empty?
      word += characters[i] } unless index == 0
       
    relatedword["start_index"] = word.length
    word = word.reverse + newchar
    
    (index + 1).upto(14) {|i|
      break if characters[i].empty?
      word += characters[i] } unless index == 14
    
    # write details of solution to hash
    case direction
      when :horizontal
        relatedword["x"] = (index - relatedword["start_index"]) + 1
        relatedword["y"] = line
      when :vertical
        relatedword["x"] = line
        relatedword["y"] = (index - relatedword["start_index"]) + 1
    end
    
    # set details of found related solution
    relatedword["direction"] = direction
    relatedword["word"] = word
    relatedword["in_dictionary"] = @wordlist.include?(word)  
    relatedword["newchars"] = [{"letter" => newchar, "index" => relatedword["start_index"]}]
    relatedword["unknowns"] = []
    
    return relatedword
  end
  
  def getline(line, direction, subemptytospace = false)
    case direction
      when :horizontal
        charsinline = @board[line -1 ].map{|char| char[0]}
      when :vertical
        charsinline = @board.transpose[line - 1].map{|char| char[0]}
    end
    
    # change empty elements of array in spaces
    charsinline.each_index{|i| charsinline[i] = " " if charsinline[i].empty?} if subemptytospace == true
    return charsinline
  end
  
  def findsolutionsinline(letters, line, direction)
    puts "Finding solutions in line " + line.to_s + ", direction " + direction.to_s + ". "
    matches = getmatches(getline(line, direction, true), letters)
    
    # add words in other direction to match
    matches.each {|m|
      relatedwords = Array.new 
      case direction
      when :horizontal
        m["x"] = m["index"] + 1
        m["y"] = line
        m["newchars"].each {|nc|
        newword = findwordaroundchar(m["x"] + nc["index"], :vertical, m["y"] - 1, nc["letter"])
        newword["unknowns"] << newword["newchars"][0]["index"] if m["unknowns"].include?(nc["index"])
        relatedwords << newword if newword["word"].length > 1
        }
      when :vertical
        m["x"] = line
        m["y"] = m["index"] + 1
        m["newchars"].each {|nc|
        newword = findwordaroundchar(m["y"] + nc["index"], :horizontal, m["x"] - 1, nc["letter"])
        newword["unknowns"] << newword["newchars"][0]["index"] if m["unknowns"].include?(nc["index"])
        relatedwords << newword if newword["word"].length > 1
        }
      end 
         
      m["relatedwords"] = relatedwords
      m["direction"] = direction   
    }
    # remove matches which have related words not in dictionary
    matches.select! {|match| match["relatedwords"].map {|w| w["in_dictionary"]}.count(false) == 0}
    return matches.uniq
  end
  
  def getmatches(characters, letters)
    letters = letters.split(//).map {|c| {"letter" => c, "unknown" => false}}
    num_unknowns = letters.map{|l| l["letter"]}.count("?")
    matches = Array.new
    permutations = Hash.new
    letter_combos = Array.new
    
    #handle unknowns
    (("a".."z").to_a.map{|c| {"letter" => c, "unknown" => true}} * num_unknowns).permutation(num_unknowns).to_a.each {|p| letter_combos << letters.reject{|l| l["letter"] == "?"} + p}
    
    #calc permutations
    for i in 1..(letters.count)
      permutations[i] = Array.new
      letter_combos.each {|letters|
        permutations[i] += letters.permutation(i).to_a.uniq
      }
      permutations[i].uniq!
    end
    
    #find matches where permutations fit
    for numchars in 1..([letters.count, characters.count(" ")].min)
      permutations[numchars].each { |perm|
        for pos in 0..(characters.count - 1)
          next if characters[pos - 1] != " " unless (pos -1) < 0
          newchars = characters[pos, characters.count]
          j = 0
          newchars.each_index{|i|
            if newchars[i] == " "
              newchars[i] = perm[j]["letter"] 
              j += 1
            end
            break if perm.count == j
          }
          word = newchars.join.split(/ /).first
          next if j != perm.count
          next if word.length <= perm.count
          unknowns = []
          perm.each_index {|i| unknowns << i if perm[i]["unknown"] == true}
          matches << {"word" => newchars.join.split(/ /).first, "index" => pos, "unknowns" => unknowns} if (word.length > 1)
        end  
      }
    end
    
    #find matches in dictionairies
    okmatches = matches.map{|m| m["word"]}.uniq & @wordlist
    matches.select! {|m| okmatches.include?(m["word"])}
    
    #get details of new related word solution
    matches.each {|m|
      newchars = Array.new
      m["word"].split(//).each_index {|i| newchars << {"letter" => m["word"].split(//)[i], "index" => i} unless characters[m["index"] + i] == m["word"].split(//)[i]}
      m["newchars"] = newchars
    }
    return matches
  end
  
  def calcpoints(calcsol)
      points = 0
      multiplier = 1
      calcsol["word"].split(//).each_index {|charindex|
        unless calcsol["unknowns"].include?(charindex) == true
          points += @scores["nl"][calcsol["word"][charindex]]
        end
        }

      calcsol["newchars"].each {|newchar|
        case calcsol["direction"]
          when :horizontal
            x = newchar["index"] + calcsol["x"]
            y = calcsol["y"]
          when :vertical
            x = calcsol["x"]
            y = newchar["index"] + calcsol["y"]
        end
        case @multiplier_template[x-1][y-1][0]
          when "DL"
            unless calcsol["unknowns"].include?(newchar["index"]) == true
              points += @scores["nl"][newchar["letter"]]
            end
          when "TL"
            unless calcsol["unknowns"].include?(newchar["index"]) == true
              points += 2 * @scores["nl"][newchar["letter"]]
            end
          when "DW"
            multiplier = multiplier * 2
          when "TW"
            multiplier = multiplier * 3
        end
      }
      return points*multiplier
    end
  
  def getsolutions(letters, numberofsolutions = 20)
    solutions = Array.new
    # horizontal
    (1..15).each {|line| 
      solutions += findsolutionsinline(letters, line, :horizontal)
      print solutions.count}
    #vertical
    (1..15).each {|line| solutions += findsolutionsinline(letters, line, :vertical)}
    
    # calculate points of solutions
    solutions.each{|solution|
      points = 0

      #get score of solution word
      points += calcpoints(solution)
      points += 40 if solution["newchars"].count == 7

      #get score of other words
      solution["relatedwords"].each{|solution_word| points += calcpoints(solution_word)}
      solution["points"] = points
    }
    
    return solutions.sort_by{|solution| solution["points"]}.reverse[0..[numberofsolutions-1, solutions.count].min]
  end
end