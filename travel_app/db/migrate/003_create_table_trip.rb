class CreateTableTrip < ActiveRecord::Migration[5.2]
    def change
        create_table :trips do |t|
            t.integer :destination_id
            t.integer :user_id
            t.datetime :depart_date
            t.datetime :return_date
            t.boolean :visited?
        end
    end
end