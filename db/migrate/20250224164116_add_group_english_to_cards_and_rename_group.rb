class AddGroupEnglishToCardsAndRenameGroup < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :groupenglish, :string, null: false
    rename_column :cards, :group, :groupgerman
  end
end
