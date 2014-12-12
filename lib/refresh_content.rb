module RefreshContent

	def highlight_saved?(new_body)
		Highlight.pluck(:body).any? { |body| body.include?(new_body) }
	end

	def clean_gfy_link(body)
		if body.include?("gfycat")
			body.gsub!(/gfycat\.com.+#.*\"/, body[/gfycat\.com\/([a-zA-Z]+)/] + '"') 	 # Strip gfycat params
		end

		body
	end

	def remove_unwanted(body)
		unwanted = ["request: ", "Request: ", "REQUEST: "]
		unwanted.each { |word| body.slice!(word) }

		body
	end

	def get_gfy_link(gif)
		response = {}

		30.times do
			response = HTTParty.get("http://upload.gfycat.com/transcode?fetchUrl=#{gif}")
			break if response.code == 200
		end

		if response.code == 200
			return "gfycat.com/#{response['gfyName']}"
		else
			return gif
		end
	end

	def gifs_to_gfy(body)
		new_body = body.dup

		body.scan(/https?:\/\/(\S+\.gifv?)\"/) do |gif|	# Get all .gifs'
			gif[0][-1] == "v" ? gfylink = gif[0][0..-2] : gfylink = gif[0]
			new_body.sub!(gif[0], get_gfy_link(gfylink))
		end
		
		new_body
	end

	def sanitize(body)
		clean_gfy_link(gifs_to_gfy(body))
	end

	def get_highlights
		response = {}

		30.times do
			response = HTTParty.get("http://www.reddit.com/r/nfl/comments/#{Week.last.urls.last}/.json?limit=10000&depth=2&sort=new")
			break if response.code == 200
		end

		week_id = Week.last.id
		latest = Highlight.maximum(:posted_on)

		response[1]["data"]["children"].each do |comment|
			break if comment["data"]["created_utc"].to_i == latest

			body = comment["data"]["body_html"]
			replies = comment["data"]["replies"]

			if !body.nil? && (body =~ /http\S+\.gifv?\"/ || body.include?("gfycat"))
				body = sanitize(body)
				Highlight.new(:body => body, :posted_on => comment["data"]["created_utc"].to_i, :week_id => week_id).save
			elsif !replies.blank?	# Get replies for requests
				replies["data"]["children"].each do |reply|
					reply_body = reply["data"]["body_html"]
					if !reply_body.nil? && (reply_body =~ /http\S+\.gifv?\"/ || reply_body.include?("gfycat"))
						body = remove_unwanted(body)	# Unwanted words only appear when it is a request
						body += sanitize(reply_body)
						Highlight.new(:body => body, :posted_on => comment["data"]["created_utc"].to_i, :week_id => week_id).save
						break
					end
				end
			end
		end
	end

	def get_thread
		response = {}

		30.times do
			response = HTTParty.get("http://www.reddit.com/r/nfl/new.json?limit=50")
			break if response.code == 200
		end

		if Time.now.in_time_zone('America/New_York').thursday?
			latest_week = Week.maximum(:week_number)
			Week.new(:week_number => latest_week+1).save
		end

		response["data"]["children"].each do |thread|
			if thread["data"]["link_flair_text"] == "Highlights"
				w = Week.last

				unless w.urls.include? thread["data"]["id"]
					w.urls << thread["data"]["id"]
					w.save
				end

				break
			end
		end
	end

	def get_user_highlights
		response = {}

		30.times do
			# Get comments from /u/fusir
			response = HTTParty.get("http://www.reddit.com/user/fusir/comments/.json?sort=new&limit=100")
			break if response.code === 200
		end

		week_id = Week.all.last.id
		week_number = Week.find(week_id).week_number
		latest = Week.maximum(:updated_at).to_i if (latest = Week.maximum(:created_at).to_i) == 0

		response["data"]["children"].each do |comment|
			next unless comment["data"]["subreddit"] == "nfl"
			break if comment["data"]["created_utc"].to_i == latest

			body = comment["data"]["body_html"]

			if !body.nil? && (body =~ /http\S+\.gifv?\"/ || body.include?("gfycat")) && !highlight_saved?(body)
				body = sanitize(body)
				Highlight.new(:body => body, :posted_on => comment["data"]["created_utc"].to_i, :week_id => week_id).save
			end
		end
	end

end
