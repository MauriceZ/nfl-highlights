class RemoveUrlsColumnFromWeeks < ActiveRecord::Migration
  def change
  	remove_column :weeks, :urls
  end
end
