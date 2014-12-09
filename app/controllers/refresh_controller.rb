require 'refresh_content'

class RefreshController < ApplicationController
	include RefreshContent

	def highlights
		get_highlights
	end

	def threads
		get_thread
	end
end
