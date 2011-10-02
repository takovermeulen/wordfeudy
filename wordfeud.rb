require 'rubygems'
require 'json'
require 'mechanize'
require 'digest/sha1'

class Wordfeud
  attr_accessor :games, :game, :board, :loggedin, :score_template
  def initialize(host = 'game01.wordfeud.com')
    @loggedin = false
    @host = host
    @agent = Mechanize.new
    @games = []
    
    @score_template = [
    [['3W',''], ['',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['3W',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['',''], ['3W','']], 
    [['',''], ['2W',''], ['',''], ['',''], ['',''], ['3L',''], ['',''], ['',''], ['',''], ['3L',''], ['',''], ['',''], ['',''], ['2W',''], ['','']], 
    [['',''], ['',''], ['2W',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['2W',''], ['',''], ['','']], 
    [['2L',''], ['',''], ['',''], ['2W',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['2W',''], ['',''], ['',''], ['2L','']], 
    [['',''], ['',''], ['',''], ['',''], ['2W',''], ['',''], ['',''], ['',''], ['',''], ['',''], ['2W',''], ['',''], ['',''], ['',''], ['','']], 
    [['',''], ['3L',''], ['',''], ['',''], ['',''], ['3L',''], ['',''], ['',''], ['',''], ['3L',''], ['',''], ['',''], ['',''], ['3L',''], ['','']], 
    [['',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['','']], 
    [['',''], ['', 'a'], ['','a'], ['', 'n'], ['',''], ['',''], ['','w'], ['','a'], ['','s'], ['',''], ['',''], ['',''], ['',''], ['',''], ['','']], 
    [['',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['','']], 
    [['',''], ['3L',''], ['',''], ['',''], ['',''], ['3L',''], ['',''], ['',''], ['',''], ['3L',''], ['',''], ['',''], ['',''], ['3L',''], ['','']], 
    [['',''], ['',''], ['',''], ['',''], ['2W',''], ['',''], ['',''], ['',''], ['',''], ['',''], ['2W',''], ['',''], ['',''], ['',''], ['','']], 
    [['2L',''], ['',''], ['',''], ['2W',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['2W',''], ['',''], ['',''], ['2L','']], 
    [['',''], ['',''], ['2W',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['2W',''], ['',''], ['','']], 
    [['',''], ['2W',''], ['',''], ['',''], ['',''], ['3L',''], ['',''], ['',''], ['',''], ['3L',''], ['',''], ['',''], ['',''], ['2W',''], ['','']], 
    [['3W',''], ['',''], ['',''], ['2L',''], ['',''], ['',''], ['',''], ['3W',''], ['',''], ['',''], ['',''], ['2L',''], ['',''], ['',''], ['3W','']], 
    ]


  end
  def login(email, password)
    url = "/wf/user/login/email/"
    password = Digest::SHA1.hexdigest(password + 'JarJarBinks9')
    data = {"email" => email, "password" => password}
    response = post(url,data)
    status = response["status"]
    if status == "success"
      @loggedin = true
    end
    return response
  end
  
  def games
      url = "/wf/user/games/"
      response = post(url)
      games = response["content"]["games"]
      games.find_all{|game| game["is_running"] == true }
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
            html << "<div class=\"tile " + "p" + @score_template[x][y][0].to_s + "\" id=\"x" + x.to_s + "y" + y.to_s + "\">" + tile[0][2] + "<\/div>"
          else
            html << "<div class=\"tile empty " + "p" + @score_template[x][y][0].to_s + "\" id=\"x" + x.to_s + "y" + y.to_s + "\">\&nbsp\;<\/div>"
          end
        end
      end
      html << "<\/div>"
    end
    html << "<\/div>"
  return html
  end
	

    
end
