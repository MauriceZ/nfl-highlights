require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

module Clockwork
	handler do |job|
		puts "Running #{job}"
	end

	# handler receives the time when job is prepared to run in the 2nd argument
	# handler do |job, time|
	#   puts "Running #{job}, at #{time}"
	# end

	every(10.seconds, 'Get Highlights') {
		Heroku::API.new.post_ps('nfl-highlights', 'rake get_highlights')
	}
end
