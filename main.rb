# Requied packages / modules
require_relative("irc.rb")
require_relative("twitch_commands.rb")
require_relative("local_commands.rb")

# Socket
init_socket
init_msg_thread	# Thread to queue up responses and respect rate limits

# Authorization Login
send_raw("PASS #{$oauth}")		# Send the password(oauth) to Twitch
send_raw("NICK #{$botname}")	# Send the botname to Twitch
send_raw("JOIN ##{$channel}")	# Send the channel to Twitch

# Thread Initialization
Thread.abort_on_exception = true
running = true

# Thread for recieving Twitch IRC data
Thread.start do
	send_msg("Connected!")

	puts "#{$botname} Joined ##{$channel}" 		# Connection Status
	puts "You should be fully connected now" 	# Connection Status
	
	while (running) do
		ready = IO.select([$socket])
		
		ready[0].each do |s|
			line = s.gets

			# Twitch PING Message
			if line.index("PING") == 0
				puts("-".bold.red * line.length)
				puts("#{"[Twitch]".bold.cyan} #{"IRC".bold.yellow}: #{line.strip.bold.green}")
				puts("-".bold.red * line.length)

				send_raw("PONG :tmi.twitch.tv\r\n")	# Respond to Twitch IRC PING message

			else
				message_data = line.match(/^:(.+)!(.+)PRIVMSG ##{$channel} :(.+)$/)

				# Message from chat
				if message_data
					user = message_data[1].chomp
					message = message_data[3].chomp

					# Command
					if message[0] == $prefix
						twitch_command(user, message)

					# Message
					else
						puts("#{"[MESSAGE]".bold.green} #{user.bold}: #{message.bold.green}")
					end
				end
			end
		end
	end
end

# Loop to keep bot going and for taking user input in console
clear_console
while (running) do
	input = gets.chomp.downcase

	if input == "disconnect"
		send_msg("Disconnecting!")
		send_msg("/disconnect")
		running = false
		exit
	end

	local_command(input)
end