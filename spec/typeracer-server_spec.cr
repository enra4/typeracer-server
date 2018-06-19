require "./spec_helper"

require "json"

describe Mapping do
	it "maps the quotes amazingly" do
		quote_json = JSON.build do |json|
			json.object do
				json.field("id", 1)
				json.field("quote", "abcdefg")
				json.field("about", "written by enra")
			end
		end

		quote = Mapping::Quote.from_json(quote_json)
		quote.id.is_a?(Int32).should(be_true)
		quote.quote.is_a?(String).should(be_true)
		quote.about.is_a?(String).should(be_true)
	end

	it "handles responses amazingly" do
		join_json = JSON.build do |json|
			json.object do
				json.field("type", "join")
				json.field("name", "abc")
				json.field("percent", nil)
				json.field("wpm", 0_f32)
			end
		end

		join = Mapping::Response.from_json(join_json)
		join.type.is_a?(String).should(be_true)
		join.name.is_a?(String).should(be_true)
		join.percent.is_a?(Int32 | Nil).should(be_true)
		join.wpm.is_a?(Float32 | Nil).should(be_true)


		update_json = JSON.build do |json|
			json.object do
				json.field("type", "update")
				json.field("name", "abc")
				json.field("percent", 42)
				json.field("wpm", 0_f32)
			end
		end

		update = Mapping::Response.from_json(update_json)
		update.type.is_a?(String).should(be_true)
		update.name.is_a?(String).should(be_true)
		update.percent.is_a?(Int32 | Nil).should(be_true)
		update.wpm.is_a?(Float32 | Nil).should(be_true)
	end
end


describe Build do
	it "builds in_game_info amazingly" do
		info = Build.in_game_info(true)
		hash = JSON.parse(info)

		hash["type"].should(eq("in_game"))
		hash["in_game"].should(eq(true))
	end

	it "builds progress_info amazingly" do
		server = Server::Server.new("0.0.0.0", 1235)
		client = TCPSocket.new
		server.@players << Player::Player.new(client, "enra")
		server.@players[0].active = true

		info = Build.progress_info(server.@players, server.@timelimit)
		hash = JSON.parse(info)

		hash["type"].should(eq("progress"))
		hash["timelimit"].should(eq(30))
		hash["players"][0]["name"].should(eq("enra"))
		hash["players"][0]["percent"].should(eq(0))
		hash["players"][0]["wpm"].should(eq(0_f32))
	end

	it "builds quote_info amazingly" do
		path = "./src/typeracer-server/quotes.json"
		quotes = Mapping::Quotes.from_json(File.read(path)).quotes
		quote = quotes[Random.rand(quotes.size)]

		info = Build.quote_info(quote)
		hash = JSON.parse(info)

		hash["type"].should(eq("quote"))
		hash["info"]["id"].as_i64.is_a?(Int64)
		hash["info"]["quote"].as_s.is_a?(String)
		hash["info"]["about"].as_s.is_a?(String)
	end
end


describe Player do
	client = TCPSocket.new
	player = Player::Player.new(client, "enra")

	it "has correct values" do
		player.@client.should(eq(client))
		player.@name.should(eq("enra"))
		player.@percent.should(eq(0))
		player.@wpm.should(eq(0_f32))
		player.@active.should(eq(false))
	end

	it "has correct types" do
		player.@client.is_a?(TCPSocket).should(be_true)
		player.@name.is_a?(String).should(be_true)
		player.@percent.is_a?(Int32 | Nil).should(be_true)
		player.@wpm.is_a?(Float32 | Nil).should(be_true)
		player.@active.is_a?(Bool).should(be_true)
	end

	it "has setters that work" do
		player.percent = 10
		player.@percent.should(eq(10))

		player.wpm = 10_f32
		player.@wpm.should(eq(10_f32))

		player.active = true
		player.@active.should(eq(true))
	end
end

describe Server do
	server = Server::Server.new("0.0.0.0", 1236)

	it "has correct values" do
		server.@players.should(eq([] of Player))
		server.@in_game.should(eq(false))
		server.@finished_quote.should(eq(false))
		server.@timelimit.should(eq(30))
	end

	it "has correct types" do
		server.@players.is_a?(Array(Player::Player)).should(be_true)
		server.@in_game.is_a?(Bool).should(be_true)
		server.@finished_quote.is_a?(Bool).should(be_true)
		server.@game_info.is_a?(Channel(String)).should(be_true)
		server.@timelimit.is_a?(Int32).should(be_true)
	end
end
