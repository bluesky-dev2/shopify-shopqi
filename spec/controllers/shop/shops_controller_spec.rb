require 'spec_helper'

describe Shop::ShopsController do

  let(:theme) { Factory :theme_woodland_dark }

  let(:shop) { Factory(:user_admin).shop }

  let(:iphone4) { Factory.build(:iphone4) }

  before :each do
    shop.themes.install theme
    request.host = "#{shop.primary_domain.host}"
  end

  describe '#preview' do

    before :each do
      shop.update_attributes password_enabled: false
    end

    it 'should show theme controll' do # 右上角显示当前预览主题提示
      get :show, preview_theme_id: shop.theme.id # 跳转后去掉preview_theme_id参数
      get :show
      response.body.should include 'theme-controls'
    end

  end

  describe '#password' do

    context '#protected' do

      it 'should be show' do
        session = mock('session')
        session.stub!(:[], 'storefront_digest').and_return(true)
        controller.stub!(:session).and_return(session)
        controller.stub!(:cart_drop).and_return({}) # 特殊处理，session.stub!(:[], 'cart')会覆盖storefront_digest
        get :show
        response.should be_success
      end

      it 'should be redirect' do
        get :show
        response.should be_redirect
      end

    end

    context '#without protected' do

      before :each do
        shop.update_attributes password_enabled: false
      end

      it 'should be show' do
        get :show
        response.should be_success
      end

      it 'should get css file' do
        get :asset, id: shop.id, theme_id: shop.theme.id, file: 'stylesheet', format: 'css'
        response.should be_success
      end

    end

  end

end
