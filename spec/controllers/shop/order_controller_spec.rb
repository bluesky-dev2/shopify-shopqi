#encoding: utf-8
require 'spec_helper'

describe Shop::OrderController do

  let(:shop) do
    model = Factory(:user).shop
    model.update_attributes password_enabled: false
    model
  end

  let(:iphone4) { Factory :iphone4, shop: shop }

  let(:variant) { iphone4.variants.first }

  let(:cart) { Factory :cart, shop: shop, cart_hash: %Q({"#{variant.id}":1}) }

  let(:order) do
    o = Factory.build :order, shop: shop
    o.line_items.build product_variant: variant, price: variant.price, quantity: 1
    o.save
    o
  end

  let(:payment) do
    Factory :payment, shop: shop
  end

  let(:billing_address_attributes) { {name: 'ma',country_code: 'CN', province: 'guandong', city: 'shenzhen', district: 'nanshan', address1: '311', phone: '13912345678' } }

  context '#address' do

    it 'should be show' do
      get :address, shop_id: shop.id, cart_token: cart.token
      response.should be_success
    end

    it 'should copy the billding address' do
      expect do
        post :create, shop_id: shop.id, cart_token: cart.token, billing_is_shipping: true, order: {
          email: 'mahb45@gmail.com',
          billing_address_attributes: billing_address_attributes
        }
        order = assigns['_resources']['order']
        order.shipping_address.name.should eql order.billing_address.name
        order.shipping_address.address1.should eql order.billing_address.address1
        order.line_items.should_not be_empty
      end.should change(Order, :count).by(1)
    end

  end

  context '#update' do
    it 'should be pay' do
      get :pay, shop_id: shop.id, token: order.token
      response.should be_success
    end

    it 'should update financial_status' do
      #china
      post :commit, shop_id: shop.id, token: order.token, order: { shipping_rate: '普通快递-10.0', payment_id: payment.id }
      order.reload.financial_status.should eql 'pending'
    end

    it 'should show product line_items' do
      #china
      order
      expect do
        post :commit, shop_id: shop.id, token: order.token, order: { shipping_rate: '普通快递-10.0', payment_id: payment.id }
        order = assigns['_resources']['order']
        order.errors.should be_empty
        order.shipping_rate.should eql '普通快递-10.0'
        order.payment_id.should eql payment.id
      end.should_not change(Order, :count)
    end

  end

end
