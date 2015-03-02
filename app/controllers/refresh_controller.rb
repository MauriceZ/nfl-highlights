class RefreshController < ApplicationController
	def highlights
		Highlight.update
	end

	def game_threads
		GameThread.update
	end
end
