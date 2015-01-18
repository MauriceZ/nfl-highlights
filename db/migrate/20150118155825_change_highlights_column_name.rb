class ChangeHighlightsColumnName < ActiveRecord::Migration
  def change
  	rename_column :highlights, :body, :body_html
  end
end
