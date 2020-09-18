class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :word
      t.text :definition

      t.timestamps
    end
  end
end
