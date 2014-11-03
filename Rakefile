# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'refresh_content'

Rails.application.load_tasks

include RefreshContent

desc "Gets the current week's new highlights"
task :get_highlights => :environment do
	get_highlights
end

desc "Gets the latest highlight thread"
task :get_thread => :environment do
	get_thread
end
