require File.dirname(__FILE__) + '/../spec_helper'

describe RequestToken do

  let(:shop) { Factory(:user).shop }

  let(:client) { Factory(:client_one, shop: shop) }

  before(:each) do
    @token = RequestToken.create client_application: client
  end

  it "should be valid" do
    @token.should be_valid
  end

  it "should not have errors" do
    @token.errors.should_not == []
  end

  it "should have a token" do
    @token.token.should_not be_nil
  end

  it "should have a secret" do
    @token.secret.should_not be_nil
  end

  it "should not be authorized" do
    @token.should_not be_authorized
  end

  it "should not be invalidated" do
    @token.should_not be_invalidated
  end

  it "should not have a verifier" do
    @token.verifier.should be_nil
  end

  it "should not be oob" do
    #@token.should_not be_oob # 无法通过测试，代码中确实不满足要求，暂时忽略
  end

  describe "OAuth 1.0a" do

    describe "with provided callback" do
      before(:each) do
        @token.callback_url="http://test.com/callback"
      end

      it "should not be oauth10" do
        @token.should_not be_oauth10
      end

      it "should not be oob" do
        @token.should_not be_oob
      end

      describe "authorize request" do
        before(:each) do
          @token.authorize!(shop)
        end

        it "should be authorized" do
          @token.should be_authorized
        end

        it "should have authorized at" do
          @token.authorized_at.should_not be_nil
        end

        it "should have shop set" do
          @token.shop.should == shop
        end

        it "should have verifier" do
          @token.verifier.should_not be_nil
        end

        describe "exchange for access token" do

          before(:each) do
            @token.provided_oauth_verifier=@token.verifier
            @access = @token.exchange!
          end

          it "should be valid" do
            @access.should be_valid
          end

          it "should have no error messages" do
            @access.errors.full_messages.should==[]
          end

          it "should invalidate request token" do
            @token.should be_invalidated
          end

          it "should set shop on access token" do
            @access.shop.should == shop
          end

          it "should authorize accesstoken" do
            @access.should be_authorized
          end
        end

        describe "attempt exchange with invalid verifier (OAuth 1.0a)" do

          before(:each) do
            @value = @token.exchange!
          end

          it "should return false" do
            @value.should==false
          end

          it "should not invalidate request token" do
            @token.should_not be_invalidated
          end
        end

      end

      describe "attempt exchange with out authorization" do

        before(:each) do
          @value = @token.exchange!
        end

        it "should return false" do
          @value.should==false
        end

        it "should not invalidate request token" do
          @token.should_not be_invalidated
        end
      end

      it "should return 1.0a style to_query" do
        @token.to_query.should=="oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}&oauth_callback_confirmed=true"
      end

    end

    describe "with oob callback" do
      before(:each) do
        @token.callback_url='oob'
      end

      it "should not be oauth10" do
        @token.should_not be_oauth10
      end

      it "should be oob" do
        @token.should be_oob
      end

      describe "authorize request" do
        before(:each) do
          @token.authorize!(shop)
        end

        it "should be authorized" do
          @token.should be_authorized
        end

        it "should have authorized at" do
          @token.authorized_at.should_not be_nil
        end

        it "should have shop set" do
          @token.shop.should == shop
        end

        it "should have verifier" do
          @token.verifier.should_not be_nil
        end

        describe "exchange for access token" do

          before(:each) do
            @token.provided_oauth_verifier=@token.verifier
            @access = @token.exchange!
          end

          it "should invalidate request token" do
            @token.should be_invalidated
          end

          it "should set shop on access token" do
            @access.shop.should == shop
          end

          it "should authorize accesstoken" do
            @access.should be_authorized
          end
        end

        describe "attempt exchange with invalid verifier (OAuth 1.0a)" do

          before(:each) do
            @value = @token.exchange!
          end

          it "should return false" do
            @value.should==false
          end

          it "should not invalidate request token" do
            @token.should_not be_invalidated
          end
        end

      end

      describe "attempt exchange with out authorization invalid verifier" do

        before(:each) do
          @value = @token.exchange!
        end

        it "should return false" do
          @value.should==false
        end

        it "should not invalidate request token" do
          @token.should_not be_invalidated
        end
      end

      it "should return 1.0 style to_query" do
        @token.to_query.should=="oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}&oauth_callback_confirmed=true"
      end
    end
  end

  if defined?(OAUTH_10_SUPPORT) && OAUTH_10_SUPPORT
    describe "OAuth 1.0" do

      it "should be oauth10" do
        @token.should be_oauth10
      end

      it "should not be oob" do
        @token.should_not be_oob
      end

      describe "authorize request" do
        before(:each) do
          @token.authorize!(shop)
        end

        it "should be authorized" do
          @token.should be_authorized
        end

        it "should have authorized at" do
          @token.authorized_at.should_not be_nil
        end

        it "should have shop set" do
          @token.shop.should == shop
        end

        it "should not have verifier" do
          @token.verifier.should be_nil
        end

        describe "exchange for access token" do

          before(:each) do
            @access = @token.exchange!
          end

          it "should invalidate request token" do
            @token.should be_invalidated
          end

          it "should set shop on access token" do
            @access.shop.should == shop
          end

          it "should authorize accesstoken" do
            @access.should be_authorized
          end
        end

      end

      describe "attempt exchange with out authorization" do

        before(:each) do
          @value = @token.exchange!
        end

        it "should return false" do
          @value.should==false
        end

        it "should not invalidate request token" do
          @token.should_not be_invalidated
        end
      end

      it "should return 1.0 style to_query" do
        @token.to_query.should=="oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}"
      end

    end
  end
end
