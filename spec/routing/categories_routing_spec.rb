require "spec_helper"

describe Api::CategoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/api/categories").should route_to("api/categories#index")
    end

    it "routes to #show" do
      get("/api/categories/1").should route_to("api/categories#show", :id => "1")
    end

    it "routes to #create" do
      post("/api/categories").should route_to("api/categories#create")
    end

    it "routes to #update" do
      put("/api/categories/1").should route_to("api/categories#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/api/categories/1").should route_to("api/categories#destroy", :id => "1")
    end

  end
end
