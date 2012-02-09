module RightnowOms
  class ApplicationController < ActionController::Base
    before_filter :remove_null_params

    protected
    def remove_null_params(data = params)
      data.each do |k, v|
        remove_null_params(v) if v.is_a? Hash
        data[k] = nil if v == 'null'
      end
    end
  end
end
