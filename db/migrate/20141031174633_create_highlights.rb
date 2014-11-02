class CreateHighlights < ActiveRecord::Migration
  def change
    create_table :highlights do |t|
      t.text :body
      t.timestamp :posted_on
      t.belongs_to :week
      t.timestamps
    end
  end
end
