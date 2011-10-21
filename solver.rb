require 'rubygems'
# hallo
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
  def getcharsinrow(row)
    chars = Array.new
    for y in 0..14
      chars << @board[row - 1][y][0]
    end
    return chars
  end
  def getcharsincol(col)
    chars = Array.new
    for x in 0..14
      chars << @board[x][col - 1][0]
    end
    return chars
  end
  def findpermutations(letters, required)
    letters = letters.downcase.split(//)
    requiredregex = "^"
    required.each do |char|
      if char != ""
        requiredregex = requiredregex + char
      else
        requiredregex = requiredregex + ".?"
      end
    end
    requiredregex = Regexp.new("^" + requiredregex + "$")
    
    permutations = Array.new
    2.upto(letters.count) { |i|
      letters.permutation(i).to_a.each do |perm|
        permutations << perm.join if perm.join =~ requiredregex
      end
    }
    return permutations
  end
  def checkwordonboard(word, row, position)
    position = position - 1
    word = word.split(//)
    charsinrow = getcharsinrow(row)[position..(position+word.count)]
    return false if charsinrow.join == ""
    return false if (position + word.count) > 15
    word.each_index {|index|     
        charsinrow[index] = "" if charsinrow[index] == word[index]
        }
    
    # removing empty array elements
    return false if charsinrow.join.split(//).count > 0
    
    return true
  end
  
  def findboardwords(letters)
    wordlist = Array.new  
    for row in 1..1
      charsasstring = getcharsinrow(row).delete_if { |char| char == "" }.join
      if charsasstring.length > 0    
        findpermutations(letters + charsasstring, getcharsinrow(row)).each do |word|
          for position in 1..15
            if checkwordonboard(word, row, position) == true
              wordlist << {"word" => word, "y" => row, "x" => position, "orientation" => :horizontal}
            end
          end
        end
      end
    end
    wordlist.uniq!
    matchedwords = wordlist.map {|solution| solution["word"]} & @wordlist
    wordlist.delete_if {|solution| matchedwords.include?(solution["word"]) == false}
    return wordlist
  end
end

board = [[["t",false],["",false],["s",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["t",false]],
[["e",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["s",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["t",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
[["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false],["",false]],
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

sol = Solver.new(board,multiplier)
letters = "test"
puts sol.findboardwords(letters)


