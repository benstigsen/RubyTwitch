# Local Commands
def local_command(command)
	response =
	case command.split(" ").first

	when "clear"
	    clear_console
    else
    	puts("Unrecognized Command!")
    end
end

def clear_console
	system "clear" or system "cls"
	puts("")
	puts("Type \"clear\" to clear the console")
	puts("Type \"disconnect\" to disconnect")
	puts("")
end