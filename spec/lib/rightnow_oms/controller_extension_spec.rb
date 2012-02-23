require 'spec_helper'

class FakeController
  include RightnowOms::ControllerExtension

  attr_accessor :session

  def initialize
    @session = {}
  end
end

module RightnowOms
  describe ControllerExtension do
    let(:controller) { FakeController.new }

    describe '#load_or_create_cart' do
      let(:cart) { FactoryGirl.build(:cart, id: 1) }

      context 'when no cart exists' do
        before { Cart.should_receive(:create).and_return(cart) }

        context 'and cart name is not set' do
          before do
            controller.load_or_create_cart
          end

          it 'only sets current_cart_id in session' do
            controller.session[:current_cart_id].should == cart.id
            controller.session.keys.should have(1).item
          end
        end

        context 'and cart name is set' do
          before { controller.load_or_create_cart(:booking) }

          it 'sets booking_cart_id' do
            controller.session[:booking_cart_id].should == cart.id
          end

          it 'sets current_cart_id as the same as booking_cart_id' do
            controller.session[:current_cart_id].should == cart.id
          end
        end
      end

      context 'when a booking cart exists' do
        before do
          controller.session[:booking_cart_id] = cart.id
          controller.session[:current_cart_id] = cart.id
          Cart.should_receive(:find_by_id).with(cart.id).and_return(cart)
        end

        context 'and cart item is not set' do
          before { controller.load_or_create_cart }

          it 'does not change the current_cart_id' do
            controller.session[:current_cart_id].should == cart.id
          end

          it 'does not change the booking_cart_id' do
            controller.session[:booking_cart_id].should == cart.id
          end
        end

        context 'and cart name is set to booking' do
          before { controller.load_or_create_cart :booking }

          it 'does not change the current_cart_id' do
            controller.session[:current_cart_id].should == cart.id
          end

          it 'does not change the booking_cart_id' do
            controller.session[:booking_cart_id].should == cart.id
          end
        end

        context 'and cart name is set to instant' do
          let(:instant_cart) { FactoryGirl.build(:cart, id: 2) }

          before do
            Cart.should_receive(:create).and_return(instant_cart)
            controller.load_or_create_cart :instant
          end

          it 'changes the current_cart_id' do
            controller.session[:current_cart_id].should == instant_cart.id
          end

          it 'does not change the booking_cart_id' do
            controller.session[:booking_cart_id].should == cart.id
          end

          it 'sets the instant_cart_id' do
            controller.session[:instant_cart_id].should == instant_cart.id
          end
        end
      end
    end
  end
end
