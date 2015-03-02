class CreateGameThreads < ActiveRecord::Migration
  def change
    create_table :game_threads do |t|
      t.text :url
      t.text :reddit_id
      t.belongs_to :week
      t.timestamps
    end
  end
end
