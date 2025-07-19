# frozen_string_literal: true

module Fields
  class ProcessField
    attr_reader :field_params

    def initialize(field, field_params)
      @field = field
      @params = field_params
    end

    def call
      @field.assign_attributes(@params.except(:shape))
      process_shape(@params)
      @field.save!
    end

    private

    def process_shape(params)
      return if params[:shape].blank?

      begin
        geojson_string = params[:shape]
        parse_geojson(geojson_string)
      rescue RGeo::Error::InvalidGeometry => e
        @field.errors.add(:shape, "not valid GeoJSON: #{e.message}")
        false
      rescue JSON::ParserError => e
        @field.errors.add(:shape, "not valid GeoJSON: #{e.message}")
        false
      end
    end

    def parse_geojson(geojson_string)
      JSON.parse(geojson_string)
      geojson = RGeo::GeoJSON.decode(geojson_string, json_parser: :json)

      if geojson.is_a?(RGeo::Feature::Geometry)
        @field.shape = geojson
      elsif geojson.is_a?(RGeo::GeoJSON::FeatureCollection)
        polygons = geojson.map(&:geometry)
        @field.shape = polygons.first.factory.multi_polygon(polygons)
      else
        @field.shape = geojson
      end
    end
  end
end
