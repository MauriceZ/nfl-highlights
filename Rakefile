# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc "Updates the current week's new highlights"
task :update_highlights => :environment do
	Highlight.update
end

desc "Updates the latest highlight thread"
task :update_thread => :environment do
	GameThread.update
end

desc "Format all the highlights for new conventions"
task :create_threads => :environment do
	Week.all.each do |week|
		week.urls.each do |url|
			full_url = "http://www.reddit.com/r/nfl/comments/#{url}/"
			week.game_threads.create(url: full_url, reddit_id: url).save
		end
	end
end
