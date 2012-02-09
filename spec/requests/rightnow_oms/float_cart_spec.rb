# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "Float cart", js: true do

  describe "GET /products" do
    subject { page }

    context "without any cart item" do
      before do
        visit '/products'
      end

      it { should have_content("购物车 0 件") }
      it { should have_content("去结算 >>") }
      it { should have_content("总计：￥0.00") }
    end
  end

  describe "Adding cart items" do
    before(:all) do
      DatabaseCleaner.strategy = nil
      FactoryGirl.create(:product, name: 'product', price: 3)
    end

    after(:all) do
      Product.destroy_all
      DatabaseCleaner.strategy = :transaction
    end

    context "when adding a new product" do
      before do
        visit '/products'
        find('button').click

        visit '/products'
      end

      it { should have_content("购物车 1 件") }
      it { should have_content("去结算 >>") }
      it { should have_content("product") }
      it { should have_content("3.0x1") }
      it { should have_content("删除") }
      it { should have_content("总计：￥3.00") }
    end
    
    context "when adding a product which have been added" do
      before do
        visit '/products'
        find('button').click
        find('button').click

        visit '/products'
      end

      it { should have_content("购物车 2 件") }
      it { should have_content("去结算 >>") }
      it { should have_content("product") }
      it { should have_content("6.0x2") }
      it { should have_content("删除") }
      it { should have_content("总计：￥6.00") }
    end


    #context "when adding product with children" do
      #before(:all)
      #let(:parent_product) { FactoryGirl.create(:product, name: 'parent', price: 1) }
      #let(:child_product) { FactoryGirl.create(:product, name: 'child', price: 2, parent: parent_product) }
    #end
  end
end
