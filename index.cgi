#!/usr/bin/env /usr/local/bin/ruby-1.9.2-p290
require 'cgi'
require 'cgi/session'
require 'rubygems'
require 'cgi_exception'
require_relative 'wordfeud.rb'
require 'erb'

cgi = CGI.new
@sess = CGI::Session.new( cgi, "session_key" => "wordfeudy",
                              "prefix" => "rubysess.")
                      
puts cgi.header
params = cgi.params
@message = "\&nbsp\;"
@form_input = "\&nbsp\;"
@board = "\&nbsp\;"

def loginform
  @form_input = "<h1>Log in \n</h1>"
  @form_input << "<form method=\"post\" action=\"index.cgi\">"
  @form_input << "<input type=\"text\" name=\"email\" value=\"\"><br>"
  @form_input << "<input type=\"password\" name=\"password\" value=\"\"><br>"
    @form_input << "<input type=\"submit\" name=\"submit\" value=\"log in\">"
  @form_input << "<input type=\"hidden\" name=\"action\" value=\"login\">"
  @form_input << "<\/form>"
end

def loginsession
  @wf = Wordfeud.new
  @wf.login(@sess["email"], @sess["password"])
end

def showgames(userid)
  loginsession
  @form_input << "<h1>Current games<\/h1>"
  games = @wf.games(userid)
  if not games.empty?    
    if not games.select{|game| game["my_turn"] == true}.empty?
      @form_input << "<h2>My turn<\/h2>"
    end
    games.select{|game| game["my_turn"] == true}.each do |game|
      @form_input << "<a href=\"index.cgi?action=board&gameid=" + game["gameid"].to_s + "\">" + "Game against " + game["opponent"].to_s + " (me: " + game["my_score"].to_s + ", opponent: " + game["opponent_score"].to_s + ")<\/a><br>"
    end
    if not games.select{|game| game["my_turn"] == false}.empty?
      @form_input << "<h2>Waiting for opponent\'s turn<\/h2>"
    end
    games.select{|game| game["my_turn"] == false}.each do |game|
      @form_input << "<a href=\"index.cgi?action=board&gameid=" + game["gameid"].to_s + "\">" + "Game against " + game["opponent"].to_s + " (me: " + game["my_score"].to_s + ", opponent: " + game["opponent_score"].to_s + ")<\/a><br>"
    end
  else
    @form_input << "No currently active games found"
  end
end

case params["action"][0] 
	when "board"
    loginsession
	  @board = @wf.printboardhtml(params["gameid"][0])  
	  showgames(@sess["userid"])
	when "games"
	  showgames(@sess["userid"])
  when "login"
    @wf = Wordfeud.new
  	resp = @wf.login(params["email"][0], params["password"][0])
  	if resp["status"] == "success"
  	  @sess["email"] = params["email"][0]
  	  @sess["password"] = params["password"][0]
  	  @sess["userid"] = resp["content"]["id"]
  	  @message = "Logged in"
  	  showgames(@sess["userid"])
  	else
  	  @message = resp.to_s
  	  loginform
  	end
  else
    loginform
end



html = File.read('template.html')
erb = ERB.new(html)
puts erb.result
