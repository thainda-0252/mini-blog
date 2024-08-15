require "rails_helper"
include SessionsHelper

RSpec.describe V1::FollowsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:followee) { create(:user) }


  before do
    log_in user
  end

  describe "POST /v1/follows" do
    context "when following a user successfully" do
      it "creates a follow and returns success" do
        post :create, params: { followee_id: followee.id }
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["message"]).to eq(I18n.t("follows.create.success"))
        expect(parsed_body["user"]["id"]).to eq(followee.id)
      end
    end

    context "when trying to follow an already followed user" do
      let!(:follow) { create(:follow, follower: user, followee: followee) }

      it "returns an error message" do
        post :create, params: { followee_id: followee.id }
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["success"]).to be_falsey
        expect(parsed_body["message"]).to eq(I18n.t("follows.create.already_followed"))
      end
    end

    context "when following a non-existent user" do
      it "returns an error message" do
        post :create, params: { followee_id: -1 }
        expect(response).to have_http_status(:not_found)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["success"]).to be_falsey
        expect(parsed_body["message"]).to eq(I18n.t("follows.create.user_not_found"))
      end
    end
  end

  describe "DELETE /v1/follows/:id" do
    let!(:follow) { create(:follow, follower: user, followee: followee) }

    context "when unfollowing successfully" do
      it "removes the follow and returns success" do
        expect {
          delete :destroy, params: { id: follow.id }
        }.to change { Follow.count }.by(-1)
        expect(response).to have_http_status(:ok)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["success"]).to be_truthy
        expect(parsed_body["message"]).to eq(I18n.t("follows.destroy.success"))
        expect(parsed_body["user"]["id"]).to eq(followee.id)
      end
    end

    context "when trying to unfollow a non-existent follow record" do
      it "returns an error message" do
        delete :destroy, params: { id: -1 } 
        expect(response).to have_http_status(:unprocessable_entity)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["success"]).to be_falsey
        expect(parsed_body["message"]).to eq(I18n.t("follows.destroy.fail"))
      end
    end
  end
end
