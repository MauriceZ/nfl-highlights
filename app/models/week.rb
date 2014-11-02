class Week < ActiveRecord::Base
	has_many :highlights
	serialize :urls, Array
end
