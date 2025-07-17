require 'rails_helper'

RSpec.describe Field, type: :model do
  it "should calculate area before saving" do
    field = Field.new(name: "Test Field", shape: "POLYGON((0 0, 1 1, 1 0, 0 0))")
    field.save
    expect(field.area).to be > 0
  end

  it "should return shape as GeoJSON" do
    field = Field.new(name: "Test Field", shape: "POLYGON((0 0, 1 1, 1 0, 0 0))")
    expect(field.as_geojson).to include("type")
    expect(field.as_geojson).to include("coordinates")
  end

  it "should process shape from params" do
    field = Field.new(name: "Test Field")
    params = { shape: '{"type":"Polygon","coordinates":[[[0,0],[1,1],[1,0],[0,0]]]}'}
    field.process_shape(params)
    expect(field.shape).to be_a(RGeo::Feature::Polygon)
  end

  describe "validations" do
    
    it "should be not valid when name is nil" do
      field = Field.new(name: nil, shape: "POLYGON((0 0, 1 1, 1 0, 0 0))")
      expect(field).not_to be_valid
      expect(field.errors[:name]).to include("can't be blank")
    end
  end
end
