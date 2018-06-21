require "socket"

module Player
	class Player
		property percent : Int32 | Nil
		property wpm : Float32 | Nil
		property active : Bool
		getter client : TCPSocket
		getter name : String

		def initialize(@client, @name)
			@percent = 0
			@wpm = 0_f32
			@active = false
		end
	end
end
