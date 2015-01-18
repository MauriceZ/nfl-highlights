module RefreshContent

	def highlight_saved?(new_body)
		Highlight.pluck(:body).any? { |body| body.include?(new_body) }
	end

	def put_gfy_info(a, url)
		gfy_id = url.scan(/gfycat\.com\/(\w+)/)[0][0]
		
		gfy_response = ""
		10.times do
			gfy_response = HTTParty.get("http://gfycat.com/cajax/get/#{gfy_id}")
			break if gfy_response.code == 200
		end

		if gfy_response['error']
			return "error"
		else
			gfy_response = gfy_response['gfyItem']
		end
		
		a['href'] = "http://gfycat.com/#{gfy_id}"
		a['data-mp4'] = gfy_response['mp4Url']
		a['data-webm'] = gfy_response['webmUrl']
	end

	def gif_to_gfy(a, url)
		gfy_response = ""
		10.times do 
			gfy_response = HTTParty.get("http://upload.gfycat.com/transcode?fetchUrl=#{url}")
			break if gfy_response.code == 200
		end

		if gfy_response['error']
			return "error"
		end

		a['href'] = "http://gfycat.com/#{gfy_response['gfyName']}"
		a['data-mp4'] = gfy_response['mp4Url']
		a['data-webm'] = gfy_response['webmUrl']
	end

	def get_streamable_vid(url)
		str_response = ""
		10.times do
			str_response = HTTParty.get(url);
			break if str_response.code == 200
		end

		return "error" if !str_response.blank?

		html = Nokogiri::HTML(str_response)
		html.at_css('source')['src']
	end

	def get_vine_vid(url)
		vine_response = ""
		10.times do
			vine_response = HTTParty.get(url);
			break if vine_response.code == 200
		end

		return "error" if !vine_response.blank?

		html = Nokogiri::HTML(vine_response)
		video = html.at_css('video')['src']
		video.scan(/\S+\.mp4/)[0]
	end

	def remove_unwanted(body)
		unwanted = ["request: ", "Request: ", "REQUEST: "]
		unwanted.each { |word| body.slice!(word) }

		body
	end

	def sanitize(body)
		body_html = Nokogiri::HTML(CGI.unescapeHTML(body))

		body_html.css("a").each do |a|
			href = a['href']

			if href.include?("imgur") && href.include?(".gif")
				a['data-mp4'] = href.scan(/(\S+)\.gif/)[0][0] + ".mp4"
				a['data-webm'] = href.scan(/(\S+)\.gif/)[0][0] + ".webm"
			elsif href.include?("gfycat")
				# a is updated inside method
				put_gfy_info(a, href)
			elsif href.include?("streamable")
				vid_url = get_streamable_vid(href)
				a['data-mp4'] = vid_url unless vid_url == "error"
				a['data-webm'] = ""
				a['class'] = "has-sound";
			elsif href.include?("vine.co")
				vid_url = get_vine_vid(href)
				a['data-mp4'] = vid_url unless vid_url == "error"
				a['data-webm'] = ""
				a['class'] = "has-sound";
			elsif href.include?(".gif")
				# a is updated inside method
				gif_to_gfy(a, href)
			end
		end

		body_html.to_html
	end

	def is_highlight?(body)
		!body.nil? && (body =~ /http\S+\.gifv?\"/ || body.include?("gfycat.com") || body.include?("streamble.com/") || body.include?("vine.co/"))
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

			body_html = comment["data"]["body_html"]
			body_text = Nokogiri::HTML(CGI.unescapeHTML(body_html)).content
			replies = comment["data"]["replies"]

			if is_highlight?(body_html)

				body_html = sanitize(body_html)
				Highlight.new(:body_html => body_html, :posted_on => comment["data"]["created_utc"].to_i, :week_id => week_id, :body_text => body_text).save

			elsif !replies.blank?	# Get replies for requests

				replies["data"]["children"].each do |reply|
					reply_body = reply["data"]["body_html"]

					if is_highlight?(reply_body)
						body_html = remove_unwanted(body_html)	# Unwanted words only appear when it is a request
						body_html += sanitize(reply_body)
						body_text = remove_unwanted(body_text)
						Highlight.new(:body_html => body_html, :posted_on => comment["data"]["created_utc"].to_i, :week_id => week_id, :body_text => body_text).save
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

			body_html = comment["data"]["body_html"]
			body_text = Nokogiri::HTML(CGI.unescapeHTML(body_html)).content

			if is_highlight?(body_html) && !highlight_saved?(body_html)
				body_html = sanitize(body_html)
				Highlight.new(:body_html => body_html, :posted_on => comment["data"]["created_utc"].to_i, :week_id => week_id, :body_text => body_text).save
			end
		end
	end

end
