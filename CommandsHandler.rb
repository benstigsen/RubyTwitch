require 'open-uri'

def HandleCommands(line)
	timestamp = Time.now.to_i
	message_count = 0
	max_messages = 80 # Make sure the bot is a moderator in your channel
	# moderators = 100 messages (within a 30 second window)
	# default = 20 messages (within a 30 second window)
	# max_messages is set to 80 just to keep it safe

	user = ""
	prefix = "!"

	admin_commands = {
		#"example" => "raw socket message"
		}

	commands = [
		"commands",
		"cortexio",
		"about",
		"project",]

	replacements = [ 
		["USER", "@#{user}"], 
		["CHANNEL", "#{CHANNEL}"],
		["COMMANDS", "#{commands}"],
		["\"", ""], ["[", ""], ["]", ""]]

	if line.index("PING") == 0
		response = Ping(line)
	else
		match = line.match(/^:(.+)!(.+)PRIVMSG ##{CHANNEL} :(.+)$/)
		message = match && match[3]
		if message =~ /^/
			message.strip!
			message.downcase!
			user = match[1]	# Get username

			if message
				if message.index("!") == 0
					message = "#{message.partition(" ").first}" # Get first word

					# ----- API COMMANDS ----- #
					if message.include?(prefix + "uptime")
						response, log_msg = Uptime(user)
					elsif message.include?(prefix + "followed")
						response, log_msg = Followed(user)
					end

					# ----- ADMIN COMMANDS ----- #
					if user == CHANNEL
						admin_commands.each do |command, value|
							if message.include?(prefix + command)
								return value + "\r\n"
							end
						end
					end

					# ----- COMMANDS ----- #
					commands.each do |command|
						if message.include?(prefix + command)
							file = open("Responses/" + command + ".txt")
							response = file.read
							file.close

							response = "PRIVMSG ##{CHANNEL} :" + response
							break
						end
					end

					# ----- GLOBAL BAN PREVENTION ----- #
					if Time.now.to_i - timestamp > 30 # If more than 30 seconds has passed
						message_count = 0 # Reset "message_count"
					end

					if message_count == 0 # If "message_count" is 0
						timestamp = Time.now.to_i # Start counting to 30 again
					end
					message_count = message_count + 1
					# ----- GLOBAL BAN PREVENTION ----- #

					if response and message_count < max_messages
						replacements.each {|replacement| response.gsub!(replacement[0], replacement[1])}
						puts("[Command] ".bold.cyan + "#{user}: ".bold + "#{message}".bold.cyan)
						log_msg = "[Command] #{user}: " + message
						return response, log_msg
					else
						puts("[Command] ".bold.red + "#{user}: ".bold + "#{message}".bold.red)
					end
				else
					puts("[Message] ".bold.green + "#{user}: ".bold + "#{message}".bold.green)
					log_msg = "[Message] #{user}: " + message
					return nil, log_msg
				end
			end
		end
	end
end

# ----- TWITCH IRC CONFIRMATION MESSAGE ----- #
def Ping(line)
	line.strip!
	puts("-".bold.red*line.length)
	puts "[Twitch] ".bold.cyan + "IRC: ".bold.yellow + line.bold.green
	puts("-".bold.red*line.length)

	response = ("PONG :tmi.twitch.tv\r\n")
	log_msg = "[IRC Message]: PING :tmi.twitch.tv"
	return response, log_msg
end


# ----- API COMMANDS ----- #
def Uptime(user)
	file = open("https://decapi.me/twitch/uptime?channel=#{CHANNEL}")
	response = "#{CHANNEL} has been streaming for: " + file.read
	response = "PRIVMSG ##{CHANNEL} :" + response
	log_msg = "[Command] #{user}: !uptime"
	return response, log_msg
end

def Followed(user)
	if user != CHANNEL
		file = open("https://decapi.me/twitch/followage/#{CHANNEL}/#{user}")
		response = file.read
		if response == "Follow not found"
			response = "#{user} is not following #{CHANNEL}"
		else
			response = "#{user} has been following #{CHANNEL} for " + response
		end
		response = "PRIVMSG ##{CHANNEL} :" + response
	end

	log_msg = "[Command] #{user}: !followed"
	return response, log_msg
end


# ----- CONSOLE COMMANDS ----- #
def Project(line)
	line.slice!("project ")
	File.write("Responses/project.txt", line)
end

def Clear()
	system "clear" or system "cls"
	puts "Type \"clear\" to clear terminal"
	puts "Type \"project <text>\" to write to project file"
	puts "Type \"disconnect\" to disconnect"
	puts ""
end
