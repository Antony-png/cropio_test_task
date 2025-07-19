# frozen_string_literal: true

class CreateFields < ActiveRecord::Migration[8.0]
  def change
    create_table :fields do |t|
      t.string :name
      t.multi_polygon :shape, srid: 4326, geographic: true
      t.float :area
      t.timestamps
    end
  end
end
