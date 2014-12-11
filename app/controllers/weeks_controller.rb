class WeeksController < ApplicationController
	def index
		@weeks = Week.all
	end

	def show
		@weeks = Week.all
		@week = Week.find_by week_number: params[:week_number]
		@highlights = @week.highlights
	end
end
