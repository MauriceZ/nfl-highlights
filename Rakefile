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
			a = Highlight.new(:body => body, :posted_on => comment["data"]["created_utc"].to_i, :week_id => week_id)
			a.save
		end
	end
end
