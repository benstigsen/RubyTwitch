# Message formatting in console
class String
	def red;            "\e[31m#{self}\e[0m" end
	def yellow;        "\e[33m#{self}\e[0m" end
	def green;          "\e[32m#{self}\e[0m" end
	def cyan;           "\e[36m#{self}\e[0m" end
	def bold;           "\e[1m#{self}\e[22m" end
end

# Requied packages / modules
require('socket')
require('logger')

# Create logger
if File.file?("log.txt")
	File.delete("log.txt") # Clear previous log
end

log = Logger.new("log.txt", formatter: proc {|severity, datetime, progname, msg|
	"#{datetime}: #{msg}\n"})

# Required Info
load "credentials.txt"
log.info("Loading \"credentials.txt\"")

require_relative('CommandsHandler') # File for handling commands
log.info("Loading \"CommandsHandler.rb\"")

# -------- IGNORE -------- #
OAUTH.downcase!
BOTNAME.downcase!
CHANNEL.downcase!.gsub!("#", "")

# Save "Preparing to connect" to "log.txt"
log.info("Preparing to connect")

# Variables
socket = TCPSocket.new('irc.chat.twitch.tv', 6667)

running = true

# Authorization Login
socket.puts("PASS #{OAUTH}")					# Send the password(oauth) to Twitch
socket.puts("NICK #{BOTNAME}")					# Send the botname to Twitch
socket.puts("JOIN ##{CHANNEL}")					# Send the channel to Twitch

# Save "Connected!" to "log.txt
log.info("Joining #{CHANNEL.capitalize} as #{BOTNAME.capitalize} using OAUTH Token: #{OAUTH[6,OAUTH.length-16]}" + "*"*16)

Thread.abort_on_exception = true

# Loop (Background Thread) for recieving Twitch chat data
Thread.start do
	socket.puts("PRIVMSG ##{CHANNEL} :Connected! PogChamp") # Send "Connected!" to the Twitch channel
	log.info("Connected to chat!")

	puts "#{BOTNAME} Joined ##{CHANNEL}" # Connection Status
	puts "You should be fully connected now" # Connection Status
	puts ""
	puts "Type \"clear\" to clear terminal"
	puts "Type \"project <text>\" to write to project file"
	puts "Type \"disconnect\" to disconnect"
	puts ""
	while (running) do
		ready = IO.select([socket])
		
		ready[0].each do |s|
			line = s.gets
			if line =~ /^/
				response, log_msg = HandleCommands(line)
			end

			if response
				socket.puts(response)
				response = nil
			end

			if log_msg
				log.info(log_msg)
				log_msg = nil
			end
		end
	end
end

# Loop to keep bot going
while (running) do
	input = gets.chomp
	if input == "clear"
		Clear()

	elsif input.index("project") == 0
		Project(input)

	elsif input == "disconnect"
		socket.puts("PRIVMSG ##{CHANNEL} : Disconnected BibleThump")
		socket.puts("PART ##{CHANNEL}\r\n")
		running = false
		exit
	end
end
