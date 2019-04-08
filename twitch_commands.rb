require_relative("configurator.rb")

def twitch_command(user, command)
	puts("#{"[COMMAND]".bold.cyan} #{user.bold}: #{command.bold.cyan}")
	command.gsub!($prefix, "")

	response = 
	case command.split(" ").first

	when "ping"
		ping(user)
	else
		nil
	end

	if response != nil
		puts("#{" " * (10 + user.length + 1)} #{"\\------".bold.blue}: #{response.yellow}")
		send_msg(response)
	end
end

def ping(user)
	return "pong #{user}!"
end