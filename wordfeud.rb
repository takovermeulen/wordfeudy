require 'rubygems'
require 'json'
require 'mechanize'
require 'digest/sha1'

class Wordfeud
  attr_accessor :board
  def initialize(host = 'game01.wordfeud.com')
    @loggedin = false
    @host = host
    @agent = Mechanize.new
    @games = []
    
    @multiplier_template = [
      [['TL'], [''], [''], [''], ['TW'], [''], [''], ['DL'], [''], [''], ['TW'], [''], [''], [''], ['TL']], 
      [[''], ['DL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['DL'], ['']], 
      [[''], [''], ['DW'], [''], [''], [''], ['DL'], [''], ['DL'], [''], [''], [''], ['DW'], [''], ['']], 
      [[''], [''], [''], ['TL'], [''], [''], [''], ['DW'], [''], [''], [''], ['TL'], [''], [''], ['']], 
      [['TW'], [''], [''], [''], ['DW'], [''], ['DL'], [''], ['DL'], [''], ['DW'], [''], [''], [''], ['TW']], 
      [[''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], ['']], 
      [[''], [''], ['DL'], [''], ['DL'], [''], [''], [''], [''], [''], ['DL'], [''], ['DL'], [''], ['']], 
      [['DL'], [''], [''], ['DW'], [''], [''], [''], [''], [''], [''], [''], ['DW'], [''], [''], ['DL']], 
      [[''], [''], ['DL'], [''], ['DL'], [''], [''], [''], [''], [''], ['DL'], [''], ['DL'], [''], ['']], 
      [[''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], ['']], 
      [['TW'], [''], [''], [''], ['DW'], [''], ['DL'], [''], ['DL'], [''], ['DW'], [''], [''], [''], ['TW']], 
      [[''], [''], [''], ['TL'], [''], [''], [''], ['DW'], [''], [''], [''], ['TL'], [''], [''], ['']], 
      [[''], [''], ['DW'], [''], [''], [''], ['DL'], [''], ['DL'], [''], [''], [''], ['DW'], [''], ['']], 
      [[''], ['DL'], [''], [''], [''], ['TL'], [''], [''], [''], ['TL'], [''], [''], [''], ['DL'], ['']], 
      [['TL'], [''], [''], [''], ['TW'], [''], [''], ['DL'], [''], [''], ['TW'], [''], [''], [''], ['TL']],
      ]
    @score_template =   {"nl" => {'a' => 1,   'g' => 3,   'm' => 3,   's' => 2,   'y' => 8, '?' => 0,
    'b' => 4,   'h' => 4,   'n' => 1,    't' => 2,
    'c' => 5,   'i' => 2,   'o' => 1,   'u' => 2,   'z' => 5,
    'd' => 2,   'j' => 4,   'p' => 4,   'v' => 4,
    'e' => 1,    'k' => 3,   'q' => 10,   'w' => 5,
    'f' => 4,   'l' => 3,   'r' => 2,   'x' => 8}}

  end
  
  def login(email, password)
    url = "/wf/user/login/email/"
    password = Digest::SHA1.hexdigest(password + 'JarJarBinks9')
    data = {"email" => email, "password" => password}
    response = post(url,data)
    return response
  end
  
  def getgames
      url = "/wf/user/games/"
      response = post(url)
      games = response["content"]["games"]
      games.find_all{|game| game["is_running"] == true }
  end
  
  def games(userid)
    games = Array.new
    getgames.each do |arr|
      game = Hash.new 
      game["gameid"] = arr["id"]
      game["opponent"] = arr["players"].select{|game| game["id"] != userid}[0]["username"]
      game["opponent_score"] = arr["players"].select{|game| game["id"] != userid}[0]["score"]
      if arr["players"].select{|game| game["id"] == userid}[0]["position"] == arr["current_player"]
        game["my_turn"] = true
      else
        game["my_turn"] = false
      end
      game["my_score"] = arr["players"].select{|game| game["id"] == userid}[0]["score"]
      games << game
    end
    return games
  end
   
  def post(url, data = {})
    page = @agent.post('http://' + @host + url, data.to_json, {'Content-Type' =>'application/json'})
    parsed_json = JSON.parse(page.body)
  end
  
  def move(gameid, tiles, ruleset = 2)
    url = '/wf/game/' + gameid.to_s + '/move/'
    data = {"ruleset" => ruleset, "move" => tiles}
    puts data
    res = post(url, data) 

  end
  
  def playsolution(gameid, sol)
    tiles = Array.new
    sol["newchars"].each {|newchar|
      case sol["direction"]
        when :horizontal
          x = sol["x"] - 1 + newchar["index"]
          y = sol["y"] - 1
        when :vertical
          x = sol["x"] - 1 
          y = sol["y"] - 1 + newchar["index"]
      end
      if sol["unknowns"].include?(newchar["index"]) == true
        unknown = true
      else
        unknown = false
      end
      tiles << [x, y, newchar["letter"].upcase, unknown]
      }

    res = move(gameid, tiles)
    
  end
  
  def board(gameid)
    url = '/wf/game/' + gameid.to_s
    board = post(url)["content"]["game"]["tiles"]
  end
   
  def letters(gameid)
    url = '/wf/game/' + gameid.to_s
    letters = post(url)["content"]["game"]["players"].find {|player| 
      player["rack"] != nil}["rack"].map{|letter|
        if letter == ""
          "?"
        else
          letter
        end 
        }.join.downcase
  end
  
  def board_array(gameid)
    board = board(gameid)
    boardarray = Array.new
    for y in 0..14
      tmp = Array.new
      for x in 0..14  
        col = board.find_all{|tilex| tilex[0] == x }
        unless col.empty?
          tile = col.find_all{|tiley| tiley[1] == y }
          unless tile.empty?
            tmp << [tile[0][2].downcase, false] 
          else
            tmp << ["",false]
          end
        else
          tmp << ["",false]
        end
      end
      boardarray << tmp
    end
    return boardarray    
  end
  
  def printboardhtml(gameid)
    board = board(gameid)
    html =  "<div class=\"board\">"
    for y in 0..14
      html <<  "<div class=\"row\">"
      for x in 0..14
        col = board.find_all{|tilex| tilex[0] == x }
        unless col.empty?
          tile = col.find_all{|tiley| tiley[1] == y }
          unless tile.empty?
            html << "<div class=\"tile " + "p" + @multiplier_template[x][y][0].to_s + "\" id=\"x" + x.to_s + "y" + y.to_s + "\">" + tile[0][2].to_s + "<div class=\"score\">" + @score_template["nl"][tile[0][2].downcase].to_s + "<\/div><\/div>"
          else
            html << "<div class=\"tile empty " + "p" + @multiplier_template[x][y][0].to_s + "\" id=\"x" + x.to_s + "y" + y.to_s + "\">\&nbsp\;" + "<div class=\"multiplier\">" + @multiplier_template[x][y][0].to_s + "<\/div><\/div>"
          end
        else
            html << "<div class=\"tile empty " + "p" + @multiplier_template[x][y][0].to_s + "\" id=\"x" + x.to_s + "y" + y.to_s + "\">\&nbsp\;" + "<div class=\"multiplier\">" + @multiplier_template[x][y][0].to_s + "<\/div><\/div>"
        end
      end
      html << "<\/div>"
    end
    html << "<\/div>"
  return html
  end
    
end
