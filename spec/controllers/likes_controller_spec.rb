require "rails_helper"
include SessionsHelper

RSpec.describe LikesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:post1) { create(:post) }
  let!(:like) { create(:like, user: user, post: post1) }

  before do
    log_in user
  end

  describe "POST #create" do
    context "when the post exists" do
      it "creates a like and redirects to the post" do
        expect {
          post :create, params: { post_id: post1.id }
        }.to change(user.likes, :count).by(1)

        expect(response).to redirect_to(post1)
      end
    end

    context "when the post does not exist" do
      it "does not create a like and sets flash[:danger]" do
        expect {
          post :create, params: { post_id: -1 }
        }.not_to change { user.likes.count }

        expect(flash[:danger]).to eq(I18n.t("like.like_fail"))
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when the like exists" do
      it "deletes the like and redirects to the post" do
        expect {
          delete :destroy, params: { post_id: post1.id, id: like.id }
        }.to change { user.likes.count }.by(-1)

        expect(response).to redirect_to(like.post)
      end
    end

    context "when the like does not exist" do
      it "does not delete any like and shows an error message" do
        expect {
          delete :destroy, params: { post_id: post1.id, id: -1 }
        }.not_to change { user.likes.count }

        expect(flash[:danger]).to eq(I18n.t("like.unlike_fail"))
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
