class CreateLocales < ActiveRecord::Migration
  
  def change
    
    create_table :locales do |t|
      t.string :iso, null:false, lenth:16
    end

    create_table :encodings do |t|
      t.string :iso, null:false, length:32 
    end

    create_table :timezones do |t|
      t.string :iso, null:false, lenth:32
    end
    
  end
  
end
