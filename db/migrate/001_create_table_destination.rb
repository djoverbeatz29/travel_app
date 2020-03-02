class CreateTableDestination < ActiveRecord::Migration[5.2]
    def change
        create_table :destinations do |t|
            t.string :country
            t.integer :geonameid
            t.string :name
            t.string :subcountry
        end
    end
end