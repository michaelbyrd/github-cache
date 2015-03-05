class CreateProfile < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :username
      t.string :avatar_url
      t.string :location
      t.string :company_name
      t.integer :number_of_followers
      t.integer :number_following
      t.datetime :github_updated_at
      t.string :repos_url

      t.timestamps null: false
    end
  end
end
