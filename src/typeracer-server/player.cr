require "socket"

module Player
	class Player
		@client : TCPSocket
		@name : String
		@percent : Int32 | Nil # percent finished with typing quote
		@wpm : Float32 | Nil
		@active : Bool

		def initialize(@client, @name)
			@percent = 0
			@wpm = 0_f32
			@active = false
		end

		def percent=(value : Int32 | Nil)
			@percent = value
		end

		def wpm=(value : Float32 | Nil)
			@wpm = value
		end

		def active=(value : Bool)
			@active = value
		end
	end
end
