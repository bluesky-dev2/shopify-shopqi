# encoding: utf-8
require 'spec_helper'

describe User do

  context '#create' do

    it 'should be success' do
      expect do
        expect do
          expect do
            attrs = {
              shop_attributes: {
                name: "测试商店",
                email: 'mahb45@gmail.com',
                domains_attributes:
                  [{subdomain: "china", domain: ".myshopqi.com"}],
                province: "110000",
                city: "",
                district: "",
                address: "311",
                zip_code: "518057",
                phone: "13928458888",
                plan: "basic"
              },
              name: "马海波",
              email: "mahb45@gmail.com",
              password: "666666",
              password_confirmation: "666666",
              phone: ""
            }
            User.create attrs
          end.should change(User, :count).by(1)
        end.should change(Shop, :count).by(1)
      end.should change(ShopDomain, :count).by(1)
    end

  end

end
