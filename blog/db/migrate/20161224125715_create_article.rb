class CreateArticle < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.text :title, null: false
      t.string :content, null: false
      t.text :author
      t.timestamps
    end
  end
end
