class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :surname
      t.string :phone_no
      t.string :country_code, limit: 3
      t.string :country
      t.string :state
      t.string :city
      t.string :photo_string

      t.timestamps
    end
  end
end
