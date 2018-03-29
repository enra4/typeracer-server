require "socket"

module Player
	class Player
		@client : TCPSocket
		@name : String
		@percent : Int32 # percent finished with typing quote

		def initialize(@client, @name)
			@percent = 0
		end
	end
end
