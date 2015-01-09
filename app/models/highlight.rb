class Highlight < ActiveRecord::Base
	belongs_to :week

	def self.search(keyword)
		return [] if keyword.blank?
		where('body ILIKE ? AND body NOT ILIKE \'%&lt;table&gt;%\'', "%#{keyword}%")
	end
end
