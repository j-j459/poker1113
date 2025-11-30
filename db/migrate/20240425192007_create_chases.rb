class CreateChases < ActiveRecord::Migration[6.1]
  def change
    create_table :chases do |t|
      t.text :body
      t.string :ace
      t.string :king
      t.string :five
      t.string :four
      t.string :three
      t.string :two
      t.string :one
      t.float :queen
      t.float :jack
      t.float :ten
      t.float :nine
      t.float :eight
      t.float :seven
      t.string :six
      t.string :aa
      t.string :bb
      t.string :cc
      t.string :dd
      t.string :ee





      t.timestamps
    end

  end
end
