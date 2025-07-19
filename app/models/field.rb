# frozen_string_literal: true

class Field < ApplicationRecord
  validates :name, presence: true
  validates :shape, presence: true

  before_save :calculate_area

  def calculate_area
    wkt = shape.as_text
    query = "SELECT ST_Area(ST_GeomFromText(#{ActiveRecord::Base.connection.quote(wkt)}, 4326)::geography)"

    area_m2 = Field.connection.select_value(query)
    self.area = area_m2.to_f / 10_000.0
  end

  def as_geojson
    GeometryConverter::ToGeoJSON.new(shape).call
  end

  def as_leaflet_polygons
    GeometryConverter::ToLeafletPolygons.new(shape).call
  end
end
