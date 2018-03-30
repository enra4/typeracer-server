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
			end
		end

		join = Mapping::Response.from_json(join_json)
		join.type.is_a?(String).should(be_true)
		join.name.is_a?(String).should(be_true)
		join.percent.is_a?(Int32 | Nil).should(be_true)

		update_json = JSON.build do |json|
			json.object do
				json.field("type", "update")
				json.field("name", "abc")
				json.field("percent", 42)
			end
		end

		update = Mapping::Response.from_json(update_json)
		update.type.is_a?(String).should(be_true)
		update.name.is_a?(String).should(be_true)
		update.percent.is_a?(Int32 | Nil).should(be_true)
	end
end
