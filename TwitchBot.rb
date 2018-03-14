# Message formatting in console
class String
	def red;            "\e[31m#{self}\e[0m" end
	def yellow;        "\e[33m#{self}\e[0m" end
	def green;          "\e[32m#{self}\e[0m" end
	def cyan;           "\e[36m#{self}\e[0m" end
	def bold;           "\e[1m#{self}\e[22m" end
end

# Requied packages / modules
require 'socket'
require 'logger'
require 'open-uri'

# Create logger
File.delete("log.txt") # Clear previous log
log = Logger.new("log.txt", formatter: proc {|severity, datetime, progname, msg|
	"#{datetime}: #{msg}\n"})

# Required Info
load "credentials.txt"
log.info("Loading \"credentials.txt\"")

# -------- IGNORE -------- #
OAUTH.downcase!
BOTNAME.downcase!
CHANNEL.downcase!.gsub!("#", "")
# -------- IGNORE -------- #

# Save "Preparing to connect" to "log.txt"
log.info("Preparing to connect")

# Variables
socket = TCPSocket.new('irc.chat.twitch.tv', 6667)
send = "PRIVMSG ##{CHANNEL} :"						# shortcut for sending messages
running = true
content = nil
message_count = 0
message_limit = Time.now.to_i

# Commands
commands = ["!examplecommand","!ping"] # Add commands here
api_commands = ["!followed","!uptime"] # API commands here
admin_commands = ["!disconnect"] # Channel owner commands here

# Authorization Login
socket.puts("PASS #{OAUTH}")					# Send the password(oauth) to Twitch
socket.puts("NICK #{BOTNAME}")					# Send the botname to Twitch
socket.puts("JOIN ##{CHANNEL}")					# Send the channel to Twitch

# Save "Connected!" to "log.txt
log.info("Joining #{CHANNEL.capitalize} as #{BOTNAME.capitalize} using OAUTH Token: #{OAUTH[6,OAUTH.length-12]}" + "*"*12)
# This will add "Joining Somechannel as Bot using OAUTH Token: OAUTH:SomeTokenHereWithHid************" to log.txt

Thread.abort_on_exception = true

# Loop (Background Thread) for recieving Twitch chat data
Thread.start do
	socket.puts(send + "Connected!")				# Send "Connected!" to the Twitch channel
	puts "#{BOTNAME} Joined ##{CHANNEL}"			# Connection Status
	puts "You should be fully connected now"		# Connection Status
	puts ""
	puts "Type \"clear\" to clear terminal"
	puts ""
	while (running) do
		ready = IO.select([socket])
		
		ready[0].each do |s|
			line = s.gets
			# Respond to Twitch IRC "PING" Message
			if line.index("PING") == 0
				line.strip!
				socket.puts("PONG :tmi.twitch.tv\r\n")
				log.info("[IRC Message]: " + line)
				log.info("[IRC Response]: PONG :tmi.twitch.tv")
				puts("-".bold.red*line.length)
				puts "[Twitch] ".bold.cyan + "IRC:  ".bold.yellow + line.bold.green
				puts "[Response] ".bold.cyan + "IRC: ".bold.yellow + "PONG :tmi.twitch.tv".bold.green
				puts("-".bold.red*line.length)
			end
			match = line.match(/^:(.+)!(.+)PRIVMSG ##{CHANNEL} :(.+)$/)
			message = match && match[3]
			if message =~ /^/
				message = message.strip
				user = match[1]			# Get username

				# Twitch message limit - (Max 100 messages in 30 secs - Applies to mods and above)
				# Avoid global ban
				if Time.now.to_i - message_limit > 30 # If more than 30 seconds has passed
					message_count = 0 # Reset "message_count"
				end
				if message_count == 0 # If "message_count" is 0
					message_limit = Time.now.to_i # Start counting to 30 again
				end
				message_count = message_count + 1
			end

			# // COMMANDS // COMMANDS // COMMANDS
			if message != nil
				msg = message.downcase
				if admin_commands.include?(msg) and user == CHANNEL # ADMIN COMMANDS -> user == CHANNEL (OWNER)
					if msg.include?("!disconnect")
						socket.puts(send + "Disconnecting")	# Disconnect from the channel
						socket.puts("PART ##{CHANNEL}")		# Disconnect from the channel
						Disconnect()
						log.info("[Command] #{user}: #{message}")
					end
				user = user.capitalize	# Capitalize first letter (Cuz I'm that kind of person)
				elsif commands.include?(msg) and message_count < 80
					puts "[Command] ".bold.cyan + "#{user}: ".bold + "#{message}".bold.cyan
					if api_commands.include?(msg) # API commands
						if msg.include?("uptime")
							file = open("https://decapi.me/twitch/uptime?channel=#{CHANNEL}") # API for uptime
							content = "#{CHANNEL} has been live for: " + file.read
						elsif msg.include?("followed")
							file = open("https://decapi.me/twitch/followage/#{CHANNEL}/#{user}") # API for followed
							content = file.read
							if content == "Follow not found"
								content = "#{user} is not following #{CHANNEL}"
							else
								content = "#{user} has been following #{CHANNEL} for " + content
							end
						end
						puts "[Response] ".bold.red + "Cortexio: ".bold + "API: ".bold.yellow + "\"#{content}\"".bold.red
					else
						file = open "Responses/" + msg.gsub!("!","") + ".txt" # open matching file
						content = file.read
						file.close
						puts "[Response] ".bold.red + "Cortexio: ".bold + "File: ".bold.yellow + "\"#{msg}.txt\"".bold.red
					end
					file.close
					log.info("[Command] #{user}: #{message}")
				else
					puts "[Message] ".bold.green + "#{user}: ".bold + "#{message}".bold.green
					log.info("[Message] #{user}: #{message}")
					if message[0] == "!" # Unrecognized command
						content = "Unrecognized command: \"#{message}\" - Type !commands to see a list of available commands."
					end
				end
				# Response handling
				if content != nil
					content.gsub!("USER", "@#{user}") # Take a look at "ping.txt" to see example usage
					content.gsub!("CHANNEL", "#{CHANNEL}")
					if content.include? "COMMANDS"
						content.gsub!("COMMANDS", "#{commands}")
						content.gsub!("\"", "")
						content.gsub!("[","")
						content.gsub!("]","")
					end
					socket.puts(send + content) # Send response if any
					content = nil # Too avoid multiple messages with the same response
				end
			end
		end
	end
end

def Disconnect() # End script
	running = false
	exit
end

# Loop to keep bot going
while (running) do
	gets.chomp
end
