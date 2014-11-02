# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc "Gets the current week's new highlights"
task :get_highlights => :environment do
	response = HTTParty.get("http://www.reddit.com/r/nfl/comments/#{Week.last.urls.last}/.json?limit=10000&depth=1&sort=new")
	week_id = Week.all.last.id
	latest = Highlight.maximum(:posted_on)

	response[1]["data"]["children"].each do |comment|
		break if comment["data"]["created_utc"].to_i == latest

		body = comment["data"]["body_html"]
		if !body.nil? && body.include?("gfycat")
			h = Highlight.new(:body => body, :posted_on => comment["data"]["created_utc"].to_i, :week_id => week_id)
			h.save
		end
	end
end

desc "Gets the latest highlight thread"
task :get_thread => :environment do
	response = HTTParty.get("http://www.reddit.com/r/nfl/.json")
	date = Time.now
	latest_week = Week.maximum(:week_number)

	if date.thursday?
		w = Week.new(:week_number => latest_week+1)
		w.save
	end

	response["data"]["children"].each do |thread|
		if thread["data"]["link_flair_text"] == "Highlights"
			w = Week.last
			w.urls << thread["data"]["id"]
			w.save
			break;
		end
	end
end
