require "file"
require "random"
require "socket"

# i have no idea what im doing
module Server
	class Server
		include Build
		include Mapping
		include Player

		property players
		property in_game
		property finished_quote
		property timelimit

		def initialize(ip = "0.0.0.0", port = 1234)
			@players = [] of Player
			@in_game = false
			@finished_quote = false
			@game_info = Channel(String).new
			@timelimit = 30

			server = TCPServer.new(ip, port)
			spawn do
				while client = server.accept?
					spawn handle_client(client)
				end
			end

			spawn do
				while info = @game_info.receive
					@players.each do |player|
						player.active = true
					end

					if info == "start game"
						@finished_quote = false
						@timelimit = 30

						send_quote

						until @finished_quote
							@players.each do |player|
								if player.@percent == 100
									@timelimit = @timelimit - 1
									break
								end
							end

							send_progress
							sleep 1.seconds
						end
					end
				end
			end
		end

		private def drop_client(client)
			(0..@players.size - 1).each do |i|
				next if @players[i].@client != client
				@players[i].@client.close
				@players.delete_at(i)
				update_state
				return
			end
		end

		private def handle_client(client)
			begin
				while message = client.gets
					break if message == nil
					handle_response(client, message)
				end
			rescue
			end

			# on close, remove client from @players
			drop_client(client)
		end

		private def handle_response(client, message)
			begin
				res = Mapping::Response.from_json(message)
			rescue
				# drop client if they send weird shit
				drop_client(client)
				return
			end

			case res.type
			when "join"
				# make sure name is 16char or less
				client.close if res.name.size > 16

				# make sure nobody already uses name
				(0..@players.size - 1).each do |i|
					next if @players[i].@name != res.name
					client.close
					return
				end

				@players << Player.new(client, res.name)

				# if @players turn two theres no reason to send them in_game info
				# because theyre the one whos starting the game
				client << Build.in_game_info(@in_game) if @players.size != 2
				update_state
			when "update"
				return if @in_game == false

				@players.each do |player|
					next if player.@name != res.name
					player.percent = res.percent
					player.wpm = res.wpm
				end

				# new round if timelimit is reached
				if @timelimit == 0
					@finished_quote = true
					@game_info.send("start game")
					return
				end

				# check if everyone has finished their quotes
				@players.each do |player|
					return if (player.@percent != 100 && player.@active == true)
				end

				sleep 5.seconds
				update_state
			end
		end

		private def update_state
			if @players.size > 1 && !@in_game
				# starts game
				@in_game = true
				@game_info.send("start game")
				return
			end

			if @players.size > 1 && @in_game
				@finished_quote = true
				@game_info.send("start game")
			end

			if @players.size < 2 && @in_game
				# end game
				@in_game = false
				@finished_quote = true

				if @players.size == 1
					@players[0].@client << Build.in_game_info(@in_game)
				end
			end
		end

		private def send_progress
			return if @players.size < 2

			send_info = Build.progress_info(@players, @timelimit)
			@players.each do |player|
				player.@client << send_info
			end
		end

		private def send_quote
			# pick random quote
			path = "./src/typeracer-server/quotes.json"
			quotes = Mapping::Quotes.from_json(File.read(path)).quotes
			quote = quotes[Random.rand(quotes.size)]

			send_info = Build.quote_info(quote)
			@players.each do |player|
				player.percent = 0 # reset percent finished for all
				player.@client << send_info
			end
		end
	end
end
