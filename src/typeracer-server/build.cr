module Build
	def self.in_game_info(in_game)
		info = JSON.build do |json|
			json.object do
				json.field("type", "in_game")
				json.field("in_game", in_game)
			end
		end

		return info
	end

	def self.progress_info(players, timelimit)
		info = JSON.build do |json|
			json.object do
				json.field("type", "progress")
				json.field("timelimit", timelimit)
				json.field("players") do
					json.array do
						players.each do |player|
							next if player.active == false

							json.object do
								json.field("name", player.name)
								json.field("percent", player.percent)
								json.field("wpm", player.wpm)
							end
						end
					end
				end
			end
		end

		return info
	end

	def self.quote_info(quote)
		info = JSON.build do |json|
			json.object do
				json.field("type", "quote")
				json.field("info") do
					json.object do
						json.field("id", quote.id)
						json.field("quote", quote.quote)
						json.field("about", quote.about)
					end
				end
			end
		end

		return info
	end
end
