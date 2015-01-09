class Highlight < ActiveRecord::Base
	belongs_to :week

	def self.search(keyword)
		return [] if keyword.blank?
		where('body ILIKE ?', "%#{keyword}%")
	end
end
