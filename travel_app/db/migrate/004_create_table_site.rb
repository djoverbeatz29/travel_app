class CreateTableSite < ActiveRecord::Migration[5.2]
    def change
        create_table :sites do |t|
            t.string :name
            t.integer :destination_id
        end
    end
end