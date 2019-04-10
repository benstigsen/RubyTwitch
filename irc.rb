# Initiate Socket
def init_socket
	require("socket")

	$socket = TCPSocket.new("irc.chat.twitch.tv", 6667)
	$oauth, $botname, $channel = get_credentials

	$messages = Array.new
end

# Initiate Response Queue
def init_msg_thread()
	Thread.new do
		while true
			if $messages.length > 0
				send_msg($messages.shift)
			end

			sleep(2) # Let's you send a max of 30 requests every 60 seconds
			# DecAPI rate limit: 100 messages per 60 seconds
			# Twitch rate limit: 100 messages per 30 seconds
		end
	end
end

# Send chat message
def send_msg(data)
	# puts("[SENDMSG] #{data}")
	$socket.puts("PRIVMSG ##{$channel} :#{data}\r\n")
end

# Send raw data
def send_raw(data)
	# puts("[SENDRAW] #{data}")
	$socket.puts("#{data}\r\n")
end 