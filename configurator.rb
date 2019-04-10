$prefix = "!"
$max_responses = 10	# How many responses to store in array

# Initialize Logger
def init_logger(clear_previous: true)
	require('logger')

	# Create logger
	if clear_previous
		if File.file?("log.txt")
			File.delete("log.txt")
		end
	end

	log = Logger.new("log.txt", formatter: proc {
		|severity, datetime, progname, msg| 
		"#{datetime}: #{msg}\n"
	})

	return log
end

# Get Credentials
def get_credentials
	credentials = File.foreach('credentials.txt').first(3)

	oauth = credentials[0].downcase.chop
	botname = credentials[1].downcase.chop
	channel = credentials[2].downcase.gsub("#", "").chop

	return oauth, botname, channel
end

# Color output
class String
	def bold;		"\e[1m#{self}\e[0m" end

	def red;		"\e[31m#{self}\e[0m" end
	def green;		"\e[32m#{self}\e[0m" end
	def yellow;		"\e[33m#{self}\e[0m" end
	def blue;		"\e[34m#{self}\e[0m" end
	def magenta;	"\e[35m#{self}\e[0m" end
	def cyan;		"\e[36m#{self}\e[0m" end
end
