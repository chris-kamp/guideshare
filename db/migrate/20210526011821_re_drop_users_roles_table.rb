class ReDropUsersRolesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :users_roles
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
