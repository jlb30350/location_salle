class ChangeRoleTypeInUsers < ActiveRecord::Migration[7.1]
  def up
    change_column :users, :role, 'integer USING CAST(role AS integer)'
    change_column_default :users, :role, 0
  end

  def down
    change_column :users, :role, :string
    change_column_default :users, :role, nil
  end
end