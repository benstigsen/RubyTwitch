def init_socket
	require("socket")

	$socket = TCPSocket.new("irc.chat.twitch.tv", 6667)
	$oauth, $botname, $channel = get_credentials
end

def send_msg(data)
	# puts("[SENDMSG] #{data}")
	$socket.puts("PRIVMSG ##{$channel} :#{data}\r\n")
end

def send_raw(data)
	# puts("[SENDRAW] #{data}")
	$socket.puts("#{data}\r\n")
end 