require "rails_helper"
include SessionsHelper

RSpec.describe V1::UsersController, type: :controller do
  let!(:user) { create(:user) }
  let!(:user2) { create(:user, created_at: 1.day.ago) }
  let!(:user3) { create(:user, username: "testuser", email: "test@example.com") }

  before do
    log_in user
  end

  describe "GET #index" do
    context "when retrieving users successfully" do
      before do
        get :index, params: { username: "testuser" }
      end

      it "returns the correct users" do
        expect(assigns(:user_items)).to match_array([user3])
      end

      it "returns the correct pagination details" do
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["pagination"]["count"]).to eq(1)
        expect(parsed_body["pagination"]["page"]).to eq(1)
        expect(parsed_body["pagination"]["pages"]).to eq(1)
      end

      it "returns a success status" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
