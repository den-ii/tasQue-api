class ChangeCountryCodeLimitInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :country_code, :string, limit: 4
  end
end
