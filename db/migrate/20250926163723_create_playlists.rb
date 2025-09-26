class CreatePlaylists < ActiveRecord::Migration[8.0]
  def change
    create_table :playlists do |t|
      t.string :spotify_id
      t.string :name
      t.integer :track_count
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
