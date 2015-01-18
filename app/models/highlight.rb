class Highlight < ActiveRecord::Base
	belongs_to :week

	def self.search(keyword)
		return [] if keyword.blank?
		where('body_text ILIKE ? AND body_html NOT ILIKE \'%<table>%\'', "%#{keyword}%")
	end
end
