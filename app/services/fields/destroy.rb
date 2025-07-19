# frozen_string_literal: true

module Fields
  class Destroy
    def initialize(field)
      @field = field
    end

    def call
      @field.destroy
    end
  end
end
