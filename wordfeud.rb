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
    [['TW',''], ['',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['TW',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['',''], ['TW','']], 
    [['',''], ['DW',''], ['',''], ['',''], ['',''], ['TL',''], ['',''], ['',''], ['',''], ['TL',''], ['',''], ['',''], ['',''], ['DW',''], ['','']], 
    [['',''], ['',''], ['DW',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['DW',''], ['',''], ['','']], 
    [['DL',''], ['',''], ['',''], ['DW',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['DW',''], ['',''], ['',''], ['DL','']], 
    [['',''], ['',''], ['',''], ['',''], ['DW',''], ['',''], ['',''], ['',''], ['',''], ['',''], ['DW',''], ['',''], ['',''], ['',''], ['','']], 
    [['',''], ['TL',''], ['',''], ['',''], ['',''], ['TL',''], ['',''], ['',''], ['',''], ['TL',''], ['',''], ['',''], ['',''], ['TL',''], ['','']], 
    [['',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['','']], 
    [['',''], ['', 'a'], ['','a'], ['', 'n'], ['',''], ['',''], ['','w'], ['','a'], ['','s'], ['',''], ['',''], ['',''], ['',''], ['',''], ['','']], 
    [['',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['','']], 
    [['',''], ['TL',''], ['',''], ['',''], ['',''], ['TL',''], ['',''], ['',''], ['',''], ['TL',''], ['',''], ['',''], ['',''], ['TL',''], ['','']], 
    [['',''], ['',''], ['',''], ['',''], ['DW',''], ['',''], ['',''], ['',''], ['',''], ['',''], ['DW',''], ['',''], ['',''], ['',''], ['','']], 
    [['DL',''], ['',''], ['',''], ['DW',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['DW',''], ['',''], ['',''], ['DL','']], 
    [['',''], ['',''], ['DW',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['DW',''], ['',''], ['','']], 
    [['',''], ['DW',''], ['',''], ['',''], ['',''], ['TL',''], ['',''], ['',''], ['',''], ['TL',''], ['',''], ['',''], ['',''], ['DW',''], ['','']], 
    [['TW',''], ['',''], ['',''], ['DL',''], ['',''], ['',''], ['',''], ['TW',''], ['',''], ['',''], ['',''], ['DL',''], ['',''], ['',''], ['TW','']], 
    ]

    @score_template = {
    "nl" => {'a' => 1, 'g' => 3, 'm' => 3, 's' => 2, 'y' => 8,
    'b' => 3, 'h' => 4, 'n' => 1,  't' => 2, 'ij' => 4,
    'c' => 5, 'i' => 1, 'o' => 1, 'u' => 4, 'z' => 4,
    'd' => 2, 'j' => 4, 'p' => 3, 'v' => 4, 
    'e' => 1,  'k' => 3, 'q' => '10', 'w' => 5,   
    'f' => 4, 'l' => 3, 'r' => 2, 'x' => 8},
    "en" => {'a' => 1, 'e' => 1, 'i' => 1, 'l' => 1, 'n' => 1, 'o' => 1, 'r' => 1, 
    's' => 1, 't' => 1, 'u' => 1, 'd' => 2, 'g' => 2,
    'b' => 3, 'c' => 3, 'm' => 3, 'p' => 3, 'f' => 4, 
    'h' => 4, 'v' => 4, 'w' => 4, 'y' => 4, 'k' => 5, 
    'j' => 8,  'x' => 8, 'q' => 10, 'z' => 10} }

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
 
  def game(gameid)
    url = '/wf/game/' + gameid.to_s
    post(url)["content"]["game"]
  end
   
  def post(url, data = {})
    page = @agent.post('http://' + @host + url, data.to_json, {'Content-Type' =>'application/json'})
    parsed_json = JSON.parse(page.body)
  end
  
  def move(gameid, tiles, ruleset = 2)
    url = '/wf/game/' + gameid.to_s + '/move/'
    data = {"ruleset" => ruleset, "move" => tiles}
    res = post(url, data) 
    if res["status"] == "error"
      if res["content"]["type"] == "illegal_word"
        puts "This is an invalid word."
      else 
        puts "Error!"
        puts "Details: " + res.to_s
      end
    else
      puts "I made my move!"
      puts "Word:" + res["content"]["main_word"] + " for " + res["content"]["points"].to_s + " points."
    end
  end
  
  def board(gameid)
     board = game(gameid)["tiles"]
  end 
  
  def printboard(gameid)
    board = board(gameid)
    for y in 0..14
      for x in 0..14
        col = board.find_all{|tilex| tilex[0] == x }
        unless col.empty?
          tile = col.find_all{|tiley| tiley[1] == y }
          unless tile.empty?
            print tile[0][2] + ' '
          else
            print '.' + ' '
          end
        end
      end
      print "\n"
    end    
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
