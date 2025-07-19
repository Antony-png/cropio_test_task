# frozen_string_literal: true

require 'rails_helper'

def build_geojson_polygon(coordinates)
  {
    type: 'Polygon',
    properties: {},
    geometry: {
      type: 'Polygon',
      coordinates: [coordinates]
    }
  }
end

describe 'Fields', type: :request do
  let(:name) { 'Test Field' }

  let(:polygon_1) do
    [
      [-74.0, 40.0],
      [-74.1, 40.0],
      [-74.1, 40.1],
      [-74.0, 40.1],
      [-74.0, 40.0]
    ]
  end

  let(:polygon_2) do
    [
      [-74.2, 40.2],
      [-74.3, 40.2],
      [-74.3, 40.3],
      [-74.2, 40.3],
      [-74.2, 40.2]
    ]
  end

  let(:multipolygon_geojson) do
    {
      type: 'MultiPolygon',
      coordinates: [
        [polygon_1],
        [polygon_2]
      ]
    }.to_json
  end

  let(:params) do
    {
      name: name,
      shape: multipolygon_geojson
    }
  end

  describe 'POST /fields' do
    subject do
      post '/fields', params: params.to_json, headers: { 'Content-Type': 'application/json' }
    end

    it 'creates a new field with multiple polygons' do
      expect { subject }.to change(Field, :count).by(1)

      field = Field.last

      expect(field.name).to eq(name)
      expect(field.shape).to be_a(RGeo::Feature::MultiPolygon)
      expect(field.shape.geometries.size).to eq(2)
      expect(field.area).to be_within(0.001).of(18_922.25)
      expect(field.shape.geometries[0].coordinates).to eq([polygon_1])
      expect(field.shape.geometries[1].coordinates).to eq([polygon_2])
    end
  end

  describe 'PUT /fields/:id' do
    let(:field) { Field.create!(name: 'Old Field', shape: RGeo::GeoJSON.decode(multipolygon_geojson)) }
    let(:updated_name) { 'Updated Field' }

    context 'when updating only a name' do
      let(:updated_params) do
        {
          name: updated_name,
          shape: multipolygon_geojson
        }
      end

      subject do
        put "/fields/#{field.id}", params: updated_params.to_json,
                                   headers: { 'Content-Type': 'application/json' }
      end

      it 'updates only the name' do
        subject

        updated_field = field.reload

        expect(updated_field.name).to eq(updated_name)
        expect(updated_field.area).to be_within(0.01).of(18_922.25)
        expect(field.shape.geometries.size).to eq(2)
        expect(updated_field.shape.geometries[0].coordinates).to eq([polygon_1])
        expect(updated_field.shape.geometries[1].coordinates).to eq([polygon_2])
      end
    end

    context 'when updating only a shape' do
      let(:new_polygon) do
        [
          [-74.4, 40.4],
          [-74.5, 40.4],
          [-74.5, 40.5],
          [-74.4, 40.5],
          [-74.4, 40.4]
        ]
      end

      let(:updated_multipolygon_geojson) do
        {
          type: 'MultiPolygon',
          coordinates: [
            [polygon_1],
            [polygon_2],
            [new_polygon]
          ]
        }.to_json
      end

      let(:updated_params) do
        {
          name: 'Old Field',
          shape: updated_multipolygon_geojson
        }
      end

      subject do
        put "/fields/#{field.id}", params: updated_params.to_json,
                                   headers: { 'Content-Type': 'application/json' }
      end

      it 'updates only the shape' do
        subject

        updated_field = field.reload

        puts updated_field.inspect
        expect(updated_field.name).to eq('Old Field')
        expect(updated_field.shape).to be_a(RGeo::Feature::MultiPolygon)
        expect(updated_field.shape.geometries.size).to eq(3)
        expect(updated_field.area).to be_within(0.01).of(28_342.12)
      end
    end
  end
end
