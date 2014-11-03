require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'HTTParty'
require 'clockwork'

include Clockwork

every(2.minutes, 'Get Highlights') {
	get_highlights
}

# module Clockwork

	

	# min = 9
	# hour = 13

	# until hour == 23 && min == 59
	# 	every(1.week, 'Get Highlights', :at => "Sunday #{hour.to_s}:#{min.to_s.rjust(2, '0')}", :tz => 'EST') {
	# 		get_highlights
	# 	}

	# 	min = (min+10) % 60
	# 	hour += 1 if min == 9
	# end

	# min = 9
	# hour = 20

	# until hour == 23 && min == 59
	# 	every(1.week, 'Get Highlights', :at => "Monday #{hour.to_s}:#{min.to_s.rjust(2, '0')}", :tz => 'EST') {
	# 		get_highlights
	# 	}

	# 	every(1.week, 'Get Highlights', :at => "Thursday #{hour.to_s}:#{min.to_s.rjust(2, '0')}", :tz => 'EST') {
	# 		get_highlights
	# 	}

	# 	min = (min+10) % 60
	# 	hour += 1 if min == 9
	# end

	# every(1.week, 'Get Thread', :at => "Sunday 13:00", :tz => 'EST') {
	# 	get_thread
	# }
	# every(1.week, 'Get Thread', :at => "Monday 20:30", :tz => 'EST') {
	# 	get_thread
	# }
	# every(1.week, 'Get Thread', :at => "Thursday 20:30", :tz => 'EST') {
	# 	get_thread
	# }
# end

def get_highlights
	response = {}

	loop do
		response = HTTParty.get("http://www.reddit.com/r/nfl/comments/#{Week.last.urls.last}/.json?limit=10000&depth=1&sort=new")
		break if response.code === 200
	end

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

def get_thread
	response = {}

	loop do
		response = HTTParty.get("http://www.reddit.com/r/nfl/.json")
		break if response.code === 200
	end

	latest_week = Week.maximum(:week_number)

	if Time.now.thursday?
		w = Week.new(:week_number => latest_week+1)
		w.save
	end

	response["data"]["children"].each do |thread|
		if thread["data"]["link_flair_text"] == "Highlights"
			w = Week.last

			unless w.urls.include? thread["data"]["id"]
				w.urls << thread["data"]["id"] 
				w.save
			end

			break;
		end
	end
end

