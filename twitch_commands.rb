require 'open-uri'
require_relative("configurator.rb")

def twitch_command(user, command)
	puts("#{"[COMMAND]".bold.cyan} #{user.bold}: #{command.bold.cyan}")
	command.gsub!($prefix, "")

	response = 
	case command.split(" ").first

	# Regular example
	when "ping"
		ping(user)

	# File example
	when "from_file"
		from_file("example.txt")

	# API example (https://docs.decapi.me/twitch)
	when "uptime"
		uptime().string	# Convert StringIO to String

	# Default
	else
		nil

	end

	# Send chat message if there is a response
	if response != nil
		puts("#{" " * (10 + user.length + 1)} #{"\\------".bold.blue}: #{response.yellow}")
		send_msg(response)
	end
end

# File Commands
def from_file(file_name)

	return open("./responses/#{file_name}").read
end

# Regular Commands
def ping(user)
	return "pong #{user}!"
end

# API Commands
def uptime(def_msg: "")

	if def_msg != ""
		return open("https://decapi.me/twitch/uptime/#{$channel}?offline_msg=#{def_msg}")
	else
		return open("https://decapi.me/twitch/uptime/#{$channel}")
	end
end