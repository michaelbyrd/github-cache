class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.references :profile, index: true
      t.string :name
      t.string :url
      t.string :html_url
      t.integer :number_of_forks
      t.integer :number_of_stars
      t.datetime :github_updated_at
      t.integer :github_id
      t.string :language

      t.timestamps null: false
    end
    add_foreign_key :repositories, :profiles
  end
end
