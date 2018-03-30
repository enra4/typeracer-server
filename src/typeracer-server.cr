require "./typeracer-server/*"

require "file"
require "random"
require "socket"

# i have no idea what im doing
module Typeracer::Server
	include Mapping
	include Player

	@@players = [] of Player
	@@in_game = false
	@@finished_quote = false
	@@game_info = Channel(String).new

	def self.drop_client(client)
		(0..@@players.size - 1).each do |i|
			next if @@players[i].@client != client
			@@players[i].@client.close
			@@players.delete_at(i)
			self.update_state
			return
		end
	end

	def self.handle_client(client)
		begin
			while message = client.gets
				break if message == nil
				self.handle_response(client, message)
			end
		rescue
		end

		# on close, remove client from @@players
		self.drop_client(client)
	end

	def self.handle_response(client, message)
		begin
			res = Mapping::Response.from_json(message)
		rescue
			# drop client if they send weird shit
			self.drop_client(client)
			return
		end

		case res.type
		when "join"
			(0..@@players.size - 1).each do |i|
				next if @@players[i].@name != res.name
				client.close
				puts "cupcake"
				puts @@players
				return
			end

			@@players << Player.new(client, res.name)
			self.update_state
		when "update"

		end
	end

	def self.update_state
		puts @@players
		if @@players.size > 1 && !@@in_game
			# starts game
			@@in_game = true
			puts "start game"
			@@game_info.send("start")
			return
		end

		if @@players.size < 2 && @@in_game
			# end game
			@@in_game = false
			puts "end game"
		end
	end

	def self.send_progress
		return if @@players.size < 2

		send_info = JSON.build do |json|
			json.object do
				json.field("type", "progress")
				json.field("players") do
					json.array do
						@@players.each do |player|
							json.object do
								json.field("name", player.@name)
								json.field("percent", player.@percent)
							end
						end
					end
				end
			end
		end

		puts send_info
	end

	def self.send_quote
		while info = @@game_info.receive
			puts info
			if info == "start"
				# pick random quote
				path = "./src/typeracer-server/quotes.json"
				quotes = Mapping::Quotes.from_json(File.read(path)).quotes
				quote_info = quotes[Random.rand(quotes.size)].to_json

				send_info = JSON.build do |json|
					json.object do
						json.field("type", "quote")
						json.field("info", quote_info)
					end
				end

				puts send_info

				@@players.each do |player|
					player.@client << send_info
				end

				until @@finished_quote
					self.send_progress
					sleep 2.seconds
				end
			end
		end
	end

	# the actual initializing
	spawn self.send_quote

	server = TCPServer.new("localhost", 1234)
	while client = server.accept?
		spawn self.handle_client(client)
	end
end
