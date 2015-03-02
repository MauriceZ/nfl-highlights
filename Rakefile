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
