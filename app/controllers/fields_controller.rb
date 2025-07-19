# frozen_string_literal: true

class FieldsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_field, only: %i[show edit update destroy]

  def index
    @fields = Field.all
  end

  def show
    @field = Field.find_by(id: params[:id])
  end

  def new
    @field = Field.new
  end

  def edit
    @field = Field.find_by(id: params[:id])
  end

  def create
    @field = Field.new(field_params.except(:shape))

    begin
      result = Fields::ProcessField.new(@field, field_params).call
      if result
        redirect_to @field, notice: 'Field was successfully created.'
      else
        render json: { error: 'Field creation failed' }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def update
    result = Fields::ProcessField.new(@field, field_params).call
    if result
      redirect_to @field, notice: 'Field was successfully updated.'
    else
      render json: { error: 'Field not found' }, status: :unprocessable_entity
    end
  end

  def destroy
    Fields::Destroy.new(@field).call
    redirect_to fields_path, notice: 'Field was successfully deleted.'
  end

  private

  def field_params
    params.expect(field: %i[name shape])
  end

  def set_field
    @field = Field.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Field not found' }, status: :not_found
  end
end
