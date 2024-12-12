class CreateErrands < ActiveRecord::Migration[7.1]
  def change
    create_table :errands do |t|
      t.string :starting_point
      t.text :description
      t.decimal :amount
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
