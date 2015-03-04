class CreateProfile < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.text :body
      t.string :username
      t.string :avatar_url
      t.string :location
      t.string :company_name
      t.integer :number_of_followers
      t.integer :number_following
    end
  end
end
