require "acts_as_api"

require "rightnow_oms/engine"
require "rightnow_oms/controller_helpers"

ActionController::Base.send(:include, RightnowOms::ControllerHelpers)
