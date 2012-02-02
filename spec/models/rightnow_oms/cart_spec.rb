require 'spec_helper'

describe RightnowOms::Cart do
  it { should belong_to :shopper }

  it { should validate_presence_of :session_id }
end
