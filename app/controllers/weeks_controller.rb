class WeeksController < ApplicationController
	helper_method :get_week_name

	def index
		@weeks = Week.all
	end

	def show
		@weeks = Week.all
		@week = Week.find_by week_number: params[:week_number]
		@highlights = @week.highlights
	end

	def get_week_name(week_number)
		week_name = ""

		case week_number
		when 18
			week_name = "Wild Card Round"
		when 19
			week_name = "Divisional Round"
		when 20
			week_name = "Conference Championships"
		when 21
			week_name = "Superbowl"
		else
			week_name = week_number.to_s
		end

		week_name
	end
end
