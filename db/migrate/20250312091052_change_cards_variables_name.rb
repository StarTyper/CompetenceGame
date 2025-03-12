class ChangeCardsVariablesName < ActiveRecord::Migration[7.1]
  def change
    rename_column :cards, :nameenglish, :name_english
    rename_column :cards, :namegerman, :name_german
    rename_column :cards, :explanationenglish, :explanation_english
    rename_column :cards, :explanationgerman, :explanation_german
  end
end
