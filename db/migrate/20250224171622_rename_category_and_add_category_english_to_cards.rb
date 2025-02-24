class RenameCategoryAndAddCategoryEnglishToCards < ActiveRecord::Migration[7.1]
  def change
    rename_column :cards, :category, :categorygerman
    add_column :cards, :categoryenglish, :string, null: false
  end
end
