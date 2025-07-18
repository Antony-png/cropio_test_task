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
    GeometryConverter::ToGeoJSON.new(self.shape).call
  end

  def as_leaflet_polygons
    GeometryConverter::ToLeafletPolygons.new(self.shape).call
  end

  def process_shape(params)
    return unless params[:shape].present?

    begin
      geojson_string = params[:shape]
      parse_geojson(geojson_string)

    rescue RGeo::Error::InvalidGeometry => e
      self.errors.add(:shape, "not valid GeoJSON: #{e.message}")
      return false
    rescue JSON::ParserError => e
      self.errors.add(:shape, "not valid GeoJSON: #{e.message}")
      return false
    end
  end

  def parse_geojson(geojson_string)
    decoded_geojson = JSON.parse(geojson_string)
    geojson = RGeo::GeoJSON.decode(geojson_string, json_parser: :json)

    if geojson.is_a?(RGeo::Feature::Geometry)
      self.shape = geojson
    elsif geojson.is_a?(RGeo::GeoJSON::FeatureCollection)
      polygons = geojson.map(&:geometry)
      self.shape = polygons.first.factory.multi_polygon(polygons)
    else
      self.shape = geojson
    end
  end
end
