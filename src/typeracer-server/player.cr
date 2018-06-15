require "socket"

module Player
	class Player
		@client : TCPSocket
		@name : String
		@percent : Int32 | Nil # percent finished with typing quote
		@wpm : Float32 | Nil

		def initialize(@client, @name)
			@percent = 0
			@wpm = 0_f32
		end

		def percent=(value : Int32 | Nil)
			@percent = value
		end

		def wpm=(value : Float32 | Nil)
			@wpm = value
		end
	end
end
