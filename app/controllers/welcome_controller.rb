require 'refresh_content'

class WelcomeController < ApplicationController
	include RefreshContent

	def index
		case params[:func]
			when "highlights"
				get_highlights
			when "thread"
				get_thread
			else
				return
		end
	end
end
