class WeeksController < ApplicationController
	def index
		@weeks = Week.all
	end

	def show
		@weeks = Week.all
		@week = Week.find(params[:id])
		@highlights = @week.highlights
	end
end
