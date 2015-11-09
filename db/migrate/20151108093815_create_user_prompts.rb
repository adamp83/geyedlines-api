class CreateUserPrompts < ActiveRecord::Migration
  def change
    create_table :user_prompts do |t|
      t.string :keyword, :body
      t.timestamps null: false
    end
  end
end
