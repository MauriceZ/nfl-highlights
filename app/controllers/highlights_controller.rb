class HighlightsController < ApplicationController
	helper_method :get_week_name

	def index
		search if params[:search]
		@weeks = Week.all
		@title = "NFL Highlights"
	end

	def show
		@week = Week.find_by week_number: params[:week_number]
		@highlights = @week.highlights.sort_by { |arr| arr[:posted_on] }.reverse
		@heading = get_heading(@week.week_number)
		@title = "#{get_week_name(@week.week_number)} | NFL Highlights"
		@title.prepend("Week ") if @week.week_number <= 17
	end

	def get_heading(week_number)
		heading = get_week_name(week_number) + " Highlights"
		heading.prepend("Week ") if week_number <= 17
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
		@highlights = Highlight.search(params[:search]).sort_by { |arr| arr[:posted_on] }.reverse
		@heading = "Results for \"#{params[:search]}\""
		@title = "Search Results | NFL Highlights"

		render "show"
	end
end
