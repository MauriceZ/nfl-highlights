module VideoAttributes
	def self.request(url)
		10.times do
			response = HTTParty.get(url)
			return response if response.code == 200
		end

		"error"
	end

	def self.get_gfy_attr(url)
		gfy_id = url.scan(/gfycat\.com\/(\w+)/)[0][0]
		gfy_response = request("http://gfycat.com/cajax/get/#{gfy_id}")

		return "error" if gfy_response == "error"

		gfy_response = gfy_response['gfyItem']
		{
			"href" => "http://gfycat.com/#{gfy_id}",
			"mp4" => gfy_response['mp4Url'],
			"webm" => gfy_response['webmUrl'],
			"class" => ""
		}
	end

	def self.gif_to_gfy(url)
		gfy_response = request("http://upload.gfycat.com/transcode?fetchUrl=#{url}")

		return "error" if gfy_response == "error"
			
		{
			"href" => "http://gfycat.com/#{gfy_response['gfyName']}",
			"mp4" => gfy_response['mp4Url'],
			"webm" => gfy_response['webmUrl'],
			"class" => ""
		}
	end

	def self.get_streamable_attr(url)
		str_response = request(url)

		return "error" if str_response == "error"
		
		html = Nokogiri::HTML(str_response)
		{
			"href" => url,
			"mp4" => html.at_css("source")["src"],
			"webm" => "",
			"class" => "has-sound"
		}
	end

	def self.get_vine_attr(url)
		vine_response = request(url)

		return "error" if vine_response == "error"

		html = Nokogiri::HTML(vine_response)
		video = html.at_css('video')['src']

		{
			"href" => url,
			"mp4" => video.scan(/\S+\.mp4/)[0],
			"webm" => "",
			"class" => "has-sound"
		}	
	end

	def self.get_imgur_attr(url)
		{
			"href" => url + ".gifv",
			"mp4" => url + ".mp4",
			"webm" => url + ".webm",
			"class" => ""
		}
	end

	def self.get_video_attr(url)
		attr = {}

		if url.include?("imgur") && url.include?(".gif")
			attr = get_imgur_attr(url)
		elsif url.include?("gfycat")
			attr = get_gfy_attr(url)
		elsif url.include?("streamable")
			attr = get_streamable_attr(url)
		elsif url.include?("vine.co")
			attr = get_vine_attr(url)
		elsif url.include?(".gif")
			attr = gif_to_gfy(url)
		end

		attr
	end

	def self.put_video_attr(a, attr)
		a["href"] = attr["href"]
		a["data-mp4"] = attr["mp4"]
		a["data-webm"] = attr["webm"]
		a["class"] = attr["class"]
	end
end
