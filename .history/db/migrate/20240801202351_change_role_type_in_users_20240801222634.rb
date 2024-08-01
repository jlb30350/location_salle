class ChangeRoleTypeInUsers < ActiveRecord::Migration[7.1]
  def up
    # Étape 1: Ajouter une nouvelle colonne temporaire
    add_column :users, :role_int, :integer

    # Étape 2: Migrer les données
    User.reset_column_information
    User.find_each do |user|
      case user.role
      when 'client'
        user.update_column(:role_int, 0)
      when 'bailleur'
        user.update_column(:role_int, 1)
      when 'admin'
        user.update_column(:role_int, 2)
      else
        user.update_column(:role_int, 0) # valeur par défaut
      end
    end

    # Étape 3: Supprimer l'ancienne colonne
    remove_column :users, :role

    # Étape 4: Renommer la nouvelle colonne
    rename_column :users, :role_int, :role

    # Étape 5: Ajouter une valeur par défaut
    change_column_default :users, :role, 0
  end

  def down
    change_column :users, :role, :string
    change_column_default :users, :role, nil
  end
end