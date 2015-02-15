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
		@title = "#{@week.heading} | NFL Highlights"
		@heading = @week.heading + " Highlights"
	end

	def search
		@highlights = Highlight.search(params[:search]).sort_by { |arr| arr[:posted_on] }.reverse
		@heading = "Results for \"#{params[:search]}\""
		@title = "Search Results | NFL Highlights"

		render "show"
	end
end
