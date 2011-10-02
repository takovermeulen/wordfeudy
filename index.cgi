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
@input = "\&nbsp\;"
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

def showgames
  loginsession
  games = Array.new
  @wf.games.each do |arr|
    game = Hash.new 
    game["id"] = arr["id"]
    game["test"] = "bla"
    games << game  
  end
  @form_input = games
  @message = @wf.games
end

case params["action"][0] 
	when "board"
    loginsession
	  @board = @wf.printboardhtml(params["boardid"])  
	when "games"
	  showgames
  when "login"
    @wf = Wordfeud.new
  	resp = @wf.login(params["email"][0], params["password"][0])
  	if resp["status"] == "success"
  	  @sess["email"] = params["email"][0]
  	  @sess["password"] = params["password"][0]
  	  @message = "Logged in"
  	  @board = @wf.printboardhtml(88858681)
  	  @form_input = "<a href=\"index.cgi?action=board\">show board<\/a>"
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
