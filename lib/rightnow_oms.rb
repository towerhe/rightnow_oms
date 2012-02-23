require 'acts_as_api'
require 'confstruct'

require 'rightnow_oms/engine'
require 'rightnow_oms/cartable_validator'
require 'rightnow_oms/acts_as_cartable'
require 'rightnow_oms/controller_extension'
require 'rightnow_oms/controller_helpers'
require 'rightnow_oms/order_no_generator'

module RightnowOms
  @@config = ::Confstruct::Configuration.new

  def self.config
    @@config
  end

  def self.configure(&block)
    @@config.configure(&block)
  end
end

ActiveRecord::Base.extend(RightnowOms::ActsAsCartable)
ActionController::Base.send(:include, RightnowOms::ControllerExtension)
ActionController::Base.send(:helper, RightnowOms::ControllerHelpers)
ActionController::Base.send(:helper, RightnowOms::Engine.helpers)
