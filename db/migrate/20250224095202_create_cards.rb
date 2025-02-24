class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards do |t|
      t.string :category, null: false
      t.boolean :positive, null: false
      t.string :namegerman, null: false
      t.string :nameenglish, null: true
      t.text :explanationgerman, null: true
      t.text :explanationenglish, null: true
      t.string :image, null: true

      t.timestamps
    end
  end
end
