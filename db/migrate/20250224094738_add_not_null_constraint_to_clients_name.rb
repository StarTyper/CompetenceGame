class AddNotNullConstraintToClientsName < ActiveRecord::Migration[7.1]
  def change
    change_column_null :clients, :name, false
  end
end
