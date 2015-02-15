class Week < ActiveRecord::Base
	has_many :highlights
	serialize :urls, Array

	def week_name
		case self.week_number
		when 18
			"Wild Card Round"
		when 19
			"Divisional Round"
		when 20
			"Conference Championships"
		when 21
			"Pro Bowl"
		when 22
			"Super Bowl"
		else
			self.week_number.to_s
		end
	end

	def heading
		heading = self.week_name
		heading.prepend("Week ") if self.week_number <= 17

		heading
	end
end
