# encoding: utf-8

require File.dirname(__FILE__) + '/spec_helper'

describe "Cresson::App" do
  include Rack::Test::Methods

  def app
    Cresson::App.set :repo_src, '../jekyll'
    Cresson::App.new
  end

  describe "レスポンスの精査" do
    let (:result) { Hash.new }

    before :all do
      result[:filename] = ''
    end

    describe "/ へのアクセス" do
      before { get '/' }
      subject { last_response }
      it "正常なレスポンスが返ること" do
        should be_ok
      end
      it "Helloと出力されること" do
        subject.body.should == "Hello"
      end
    end

    describe "/api/v1/create_post へのアクセス" do
      before { post '/api/v1/create_post', { :post => { :title => 'title', :content => 'banana' } } }
      subject { last_response }
      it "正常なレスポンスが返ること" do
        should be_ok
      end
      it "filename が正しいこと" do
        data = JSON.parse(subject.body)
        result[:filename] = data['filename']
        result[:filename].should_not be_nil
      end
    end

    describe "/api/v1/get_posts へのアクセス" do
      before { get '/api/v1/get_posts' }
      subject { last_response }
      it "正常なレスポンスが返ること" do
        should be_ok
      end
      it "JSONが出力されること" do
        subject.header['Content-Type'].should include 'application/json'
      end
    end

    describe "/api/v1/get_post へのアクセス" do
      before { get '/api/v1/get_post/' + result[:filename] }
      subject { last_response }
      it "正常なレスポンスが返ること" do
        should be_ok
      end
      it "JSON が出力されること" do
        subject.header['Content-Type'].should include 'application/json'
      end
      it "Title が正しいこと" do
        JSON.parse(subject.body)['title'].should == 'title'
      end
      it "Content が正しいこと" do
        JSON.parse(subject.body)['content'].should == 'banana'
      end
    end

    describe "/api/v1/update_post へのアクセス" do
      before { post '/api/v1/update_post/' + result[:filename], { :post => { :title => 'title', :content => 'chocolate' } } }
      subject { last_response }
      it "正常なレスポンスが返ること" do
        should be_ok
      end
      it "filename が正しいこと" do
        data = JSON.parse(subject.body)
        result[:filename] = data['filename']
        result[:filename].should_not be_nil
      end
    end

    describe "更新後、/api/v1/get_post へのアクセス" do
      before { get '/api/v1/get_post/' + result[:filename] }
      subject { last_response }
      it "正常なレスポンスが返ること" do
        should be_ok
      end
      it "JSON が出力されること" do
        subject.header['Content-Type'].should include 'application/json'
      end
      it "Title が正しいこと" do
        JSON.parse(subject.body)['title'].should == 'title'
      end
      it "Content が正しいこと" do
        JSON.parse(subject.body)['content'].should == 'chocolate'
      end
    end

    describe "/api/v1/delete_post へのアクセス" do
      before { get '/api/v1/delete_post/' + result[:filename] }
      subject { last_response }
      it "正常なレスポンスが返ること" do
        should be_ok
      end
    end

    describe "削除後、/api/v1/get_post へのアクセス" do
      before { get '/api/v1/get_post/' + result[:filename] }
      subject { last_response }
      it "正常なレスポンスが返ること" do
        should_not be_ok
      end
    end
  end 
end
