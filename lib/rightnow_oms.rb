require "acts_as_api"

require "rightnow_oms/engine"
require "rightnow_oms/acts_as_cartable"
require "rightnow_oms/controller_helpers"

ActiveRecord::Base.extend(RightnowOms::ActsAsCartable)
ActionController::Base.send(:include, RightnowOms::ControllerHelpers)
