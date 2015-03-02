class Highlight < ActiveRecord::Base
	belongs_to :week

	def self.search(keyword)
		return [] if keyword.blank?
		where('body_text ILIKE ? AND body_html NOT ILIKE \'%<table>%\'', "%#{keyword}%")
	end

	def saved?(new_body)
		Highlight.pluck(:body_html).any? { |body| body.include?(new_body) }
	end

	def self.update
		new_posts = get_latest_posts
		parse_response(new_posts)
	end

	def self.prepare(body)
		body_html = Nokogiri::HTML(CGI.unescapeHTML(body))

		body_html.css("a").each do |a|
			next unless is_highlight?(a['href']) && a['data-mp4'].blank?

			attr = VideoAttributes::get_video_attr(a['href'])
			VideoAttributes::put_video_attr(a, attr)
		end

		body_html.to_html
	end

	private

	def self.parse_response(response)
		latest_time = Highlight.maximum(:posted_on) || 0
		response["data"]["children"].each do |comment|
			break if comment["data"]["created_utc"].to_i <= latest_time

			parent = comment["data"]["body_html"]
			replies = comment["data"]["replies"]

			if is_highlight?(parent)
				save(comment)
			elsif !replies.blank?
				parse_replies(replies, parent)
			end
		end
	end

	def self.get_latest_posts
		reddit_thread_id = Week.last.game_threads.last.reddit_id
		30.times do
			response = HTTParty.get("http://www.reddit.com/r/nfl/comments/#{reddit_thread_id}/.json?limit=10000&depth=2&sort=new")
			return response[1] if response.code == 200
		end
	end

	def self.is_highlight?(body)
		!body.nil? && (body =~ /http\S+\.gifv?/ || body.include?("gfycat.com") || body.include?("streamble.com/") || body.include?("vine.co/"))
	end

	def self.save(highlight)
		body_html = highlight["data"]["body_html"]
		body_text = Nokogiri::HTML(CGI.unescapeHTML(body_html)).content
		prepared_html = prepare(body_html)

		Week.last.highlights.create(:body_html => prepared_html, :posted_on => highlight["data"]["created_utc"].to_i, :body_text => body_text).save
	end

	def self.parse_replies(replies, parent)
		replies["data"]["children"].each do |reply|
			if is_highlight?(reply["data"]["body_html"])
				save_reply(reply, parent)
				break
			end
		end
	end

	def self.save_reply(reply, parent_html)
		parent_html = remove_unwanted_words(parent_html)
		body_html = parent_html + prepare(reply["data"]["body_html"])
		body_text = Nokogiri::HTML(CGI.unescapeHTML(body_html)).content

		Week.last.highlights.create(:body_html => body_html, :posted_on => reply["data"]["created_utc"].to_i, :body_text => body_text).save
	end

	def self.remove_unwanted_words(body)
		unwanted = ["request: ", "Request: ", "REQUEST: ", "[REQUEST]: "]
		unwanted.each { |word| body.slice!(word) }

		body
	end
end
