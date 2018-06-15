require "json"
require "socket"

module Mapping
	struct Quote
		JSON.mapping(
			id: Int32,
			quote: String,
			about: String
		)
	end

	struct Quotes
		JSON.mapping(
			quotes: Array(Quote)
		)
	end

	struct Response
		JSON.mapping(
			type: String,
			name: String,
			percent: Int32 | Nil,
			wpm: Float32 | Nil
		)
	end
end
