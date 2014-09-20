class CreateLocales < ActiveRecord::Migration
  
  def change
    
    create_table :locales do |t|
      t.string :iso, null:false, limit: 16, :charset => :ascii, :collation => :ascii_bin, :unique => true
    end

    create_table :encodings do |t|
      t.string :iso, null:false, limit: 32, :charset => :ascii, :collation => :ascii_bin, :unique => true
    end

    create_table :timezones do |t|
      t.string :iso, null:false, limit: 32, :charset => :ascii, :collation => :ascii_bin, :unique => true
    end
    
  end
  
end
