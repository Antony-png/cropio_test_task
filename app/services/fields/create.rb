module Fields
  class Create
    def initialize(field, params)
      @field = field
      @params = params
    end

    def call
      @field.assign_attributes(@params.except(:shape))
      @field.process_shape(@params) if @params[:shape].present?

      @field.save
    end
  end
end
