class GameThread < ActiveRecord::Base
	belongs_to :week

	def self.update
		if Time.now.in_time_zone('America/New_York').thursday?
			latest_week_num = Week.maximum(:week_number)
			Week.new(:week_number => latest_week_num+1).save
		end

		latest_thread = get_latest
		latest_week = Week.last
		unless latest_week.has_game_thread?(latest_thread["reddit_id"])
			latest_week.game_threads.create(url: latest_thread["url"], reddit_id: latest_thread["reddit_id"])
		end
	end

	private

	def self.request
		30.times do
			response = HTTParty.get("http://www.reddit.com/r/nfl/new.json?limit=50")
			return response if response.code == 200
		end
	end

	def self.get_latest
		threads = request
		threads["data"]["children"].each do |thread|
			if thread["data"]["link_flair_text"] == "Highlights"
				return {
					"url" => thread["data"]["url"],
					"reddit_id" => thread["data"]["id"]
				}
			end
		end
	end
end
