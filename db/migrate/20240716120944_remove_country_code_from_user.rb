class RemoveCountryCodeFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :country_code, :string
  end
end
