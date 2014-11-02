class ChangeTimestampFormatInHighlights < ActiveRecord::Migration
  def up
  	change_column :highlights, :posted_on, 'integer USING cast(extract(epoch from current_timestamp) as integer)'
  end

  def down
  	change_column :highlights, :posted_on, :datetime
  end
end
