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

desc "Gets the latest highlights from reddit users that commonly post them"
task :get_user_highlights => :environment do
	get_user_highlights
end

desc "Format all the highlights for new conventions"
task :sanitize_highlights => :environment do
	num_highlights = Highlight.all.length
	Highlight.all.each_with_index do |h, i|
		puts "ID: #{h.id}"
		puts "#{i+1} of #{num_highlights}"
		h.body_text = Nokogiri::HTML(CGI.unescapeHTML(h.body_html)).content
		h.body_html = sanitize(h.body_html)
		h.save
	end
end
