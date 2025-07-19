# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Field, type: :model do
  it 'should calculate area before saving' do
    field = Field.new(name: 'Test Field', shape: 'POLYGON((0 0, 1 1, 1 0, 0 0))')
    field.save
    expect(field.area).to be > 0
  end

  it 'should return shape as GeoJSON' do
    field = Field.new(name: 'Test Field', shape: 'POLYGON((0 0, 1 1, 1 0, 0 0))')
    expect(field.as_geojson).to include('type')
    expect(field.as_geojson).to include('coordinates')
  end

  describe 'validations' do
    context 'when name is nil' do
      it 'should be not valid' do
        field = Field.new(name: nil, shape: 'POLYGON((0 0, 1 1, 1 0, 0 0))')
        expect(field).not_to be_valid
        expect(field.errors[:name]).to include("can't be blank")
      end
    end

    context 'when shape is nil' do
      it 'should be not valid' do
        field = Field.new(name: 'Test name', shape: nil)
        expect(field).not_to be_valid
        expect(field.errors[:shape]).to include("can't be blank")
      end
    end
  end
end
