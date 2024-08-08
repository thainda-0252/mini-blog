require "rails_helper"
include SessionsHelper

RSpec.describe FollowsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    log_in user
  end

  describe "POST #create" do
    context "with valid parameteres" do
      it "follows the other user" do
        expect {
          post :create, params: { followee_id: other_user.id }
      }.to change(user.following, :count).by(1)
      end

      it "redirect to the followed user" do
        post :create, params: { followee_id: other_user.id }
        expect(response).to redirect_to(other_user)
      end

      it "redirect to turbo_stream format" do
        post :create, params: { followee_id: other_user.id }, format: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:follow) { user.active_follows.create(followee_id: other_user.id) }

    it "unfollows the other user" do
      expect {
        delete :destroy, params: { id: follow.id }
      }.to change(user.following, :count).by(-1)
    end

    it "redirects to the unfollowed user" do
      delete :destroy, params: { id: follow.id }
      expect(response).to redirect_to(other_user)
    end

    it "redirects with turbo_stream format" do
      delete :destroy, params: { id: follow.id }, format: :turbo_stream
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end
  end
end
