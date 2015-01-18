class AddBodyTextToHighlights < ActiveRecord::Migration
  def change
  	add_column :highlights, :body_text, :text
  end
end
