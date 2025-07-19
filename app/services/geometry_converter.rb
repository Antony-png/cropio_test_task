# frozen_string_literal: true

module GeometryConverter
  class ToLeafletPolygons
    def initialize(shape)
      @shape = shape
    end

    def call
      return [] if @shape.blank?

      geojson = RGeo::GeoJSON.encode(@shape)
      polygons = []

      case geojson['type']
      when 'MultiPolygon'
        geojson['coordinates'].each do |polygon_coords|
          latlngs = polygon_coords[0].map { |coord| [coord[1], coord[0]] }
          polygons << latlngs
        end
      when 'Polygon'
        latlngs = geojson['coordinates'][0].map { |coord| [coord[1], coord[0]] }
        polygons << latlngs
      end

      polygons
    end
  end

  class ToGeoJSON
    def initialize(shape)
      @shape = shape
    end

    def call
      return nil if @shape.blank?

      RGeo::GeoJSON.encode(@shape).to_json
    end
  end
end
