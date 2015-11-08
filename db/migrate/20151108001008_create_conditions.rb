class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.string :name, :url
      t.timestamps null: false
    end

    # Load conditions based on CMT guidelines
    cs = File.open("#{Rails.root}/public/conditions.txt")
    cs = cs.read.split("\n").collect{|a| a.upcase}

    cs.each do |c|
      Condition.create!(name: c)
    end
  end
end
