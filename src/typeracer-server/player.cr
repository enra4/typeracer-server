require "socket"

module Player
	class Player
		@client : TCPSocket
		@name : String
		@percent : Int32 | Nil # percent finished with typing quote

		def initialize(@client, @name)
			@percent = 0
		end

		def percent=(value : Int32 | Nil)
			@percent = value
		end
	end
end
