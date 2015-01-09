class HighlightsController < ApplicationController
	helper_method :get_week_name

	def index
		search if params[:search]
		@weeks = Week.all
	end

	def show
		@weeks = Week.all
		@week = Week.find_by week_number: params[:week_number]
		@highlights = @week.highlights.sort_by { |arr| arr[:posted_on] }.reverse
		@title = get_title(@week.week_number)
	end

	def get_title(week_number)
		if week_number <= 17
			title = "Week #{week_number} Highlights" 
		else
			title = get_week_name(week_number) + " Highlights"
		end

		title
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

	def search
		@weeks = Week.all
		@highlights = Highlight.search(params[:search])
		@title = "Results for \"#{params[:search]}\""

		render "show"
	end
end
