require "rails_helper"
include SessionsHelper

RSpec.describe PostsController, type: :controller do
  let(:user) { create :user }
  let(:other_user) { create(:user) }
  let!(:published_post) { create(:post, :published, user: other_user) }
  let!(:unpublished_post_user) { create(:post, :unpublished, user: user) }
  let!(:unpublished_post_other_user) { create(:post, :unpublished, user: other_user) }
  before { log_in user }

  describe "GET #index" do
    before { get :index }

    it "returns a successful response" do
      expect(response).to be_successful
    end

    it "assigns @post_items with viewable posts" do
      expect(assigns(:post_items)).to match_array([published_post, unpublished_post_user])
    end

    it "paginates the posts" do
      pagy, post_items = assigns(:pagy), assigns(:post_items)
      expect(pagy).to be_a Pagy
      expect(post_items.size).to be <= Settings.posts.per_page
    end
  
    context "when there are no posts" do
      before do
        Post.delete_all
      end

      it "assigns an empty array to @post_items" do
        get :index
        post_items = assigns(:post_items)
        expect(post_items).to be_empty
      end

      it "assigns pagy object" do
        get :index
        pagy = assigns(:pagy)
        expect(pagy).to be_a(Pagy)
      end
    end
  end

  describe "GET #show" do
    let!(:post) { create(:post, :unpublished, user: user) }
    context "when post is found" do
      before do 
        get :show, params: { id: post.id }
      end

      it "assigns the requested post to @post" do
        expect(assigns(:post)).to eq(post)
      end

      it "render the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when post is not found" do
      before do 
        get :show, params: { id: -1 }
      end

      it "sets a flash danger message" do
        expect(flash[:danger]).to eq(I18n.t("posts.not_found"))
      end

      it "redirects to the root path" do
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) { attributes_for(:post, content_url: fixture_file_upload(Rails.root.join("spec/fixtures/files/test_image.jpeg"), "image/jpeg")) }
    let(:invalid_params) { attributes_for(:post, caption: "") }

    context "with valid attributes" do
      it "creates a new post" do
        expect {
          post :create, params: { post: valid_params }
        }.to change(Post, :count).by(1)
      end

      it "attaches the content_url" do
        post :create, params: { post: valid_params }
        expect(Post.last.content_url).to be_attached
      end

      it "sets a success flash message" do
        post :create, params: { post: valid_params }
        expect(flash[:success]).to eq(I18n.t("posts.success"))
      end

      it "redirects to the root path" do
        post :create, params: { post: valid_params }
        expect(response).to redirect_to(root_path)
      end
    end 

    context "with invalid attributes" do
      it "does not create new post" do
        expect {
          post :create, params: { post: invalid_params }
        }.not_to change(Post, :count)
      end

      it "sets a danger flash message" do
        post :create, params: { post: invalid_params }
        expect(flash[:danger]).to eq(I18n.t("posts.fail"))
      end

      it "renders the new template with unprocessable_entity status" do
        post :create, params: { post: invalid_params }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    let(:post) { create(:post, user: user) }
    let(:valid_attributes) { attributes_for(:post, caption: "Updated caption") }
    let(:invalid_attributes) { attributes_for(:post, caption: "") }
    context "with valid attributes" do
      it "updates the post" do
        put :update, params: { id: post.id, post: valid_attributes }
        post.reload
        expect(post.caption).to eq("Updated caption")
      end

      it "sets a success flash message" do
        put :update, params: { id: post.id, post: valid_attributes }
        expect(flash[:success]).to eq(I18n.t("posts.edit.success"))
      end

      it "redirects to the posts path" do
        put :update, params: { id: post.id, post: valid_attributes }
        expect(response).to redirect_to(posts_path)
      end
    end

    context "with invalid attributes" do
      it "does not update the post" do
        put :update, params: { id: post.id, post: invalid_attributes }
        post.reload
        expect(post.caption).not_to eq("")
      end

      it "sets a danger flash message" do
        put :update, params: { id: post.id, post: invalid_attributes }
        expect(flash[:danger]).to eq(I18n.t("posts.edit.fail"))
      end

      it "renders the edit template with unprocessable_entity status" do
        put :update, params: { id: post.id, post: invalid_attributes }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:post) { create(:post, user: user) }

    context "when post is successfully destroyed" do
      it "destroys the post" do
        expect {
          delete :destroy, params: { id: post.id }
        }.to change(Post, :count).by(-1)
      end

      it "sets a success flash message" do
        delete :destroy, params: { id: post.id }
        expect(flash[:success]).to eq(I18n.t("posts.destroy.success"))
      end

      it "redirects to the posts path with status see_other" do
        delete :destroy, params: { id: post.id }
        expect(response).to redirect_to(posts_path)
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when post is not successfully destroyed" do
      before do
        allow_any_instance_of(Post).to receive(:destroy).and_return(false)
      end

      it "does not change the number of posts" do
        expect {
          delete :destroy, params: { id: post.id }
        }.not_to change(Post, :count)
      end

      it "sets a danger flash message" do
        delete :destroy, params: { id: post.id }
        expect(flash[:danger]).to eq(I18n.t("posts.destroy.fail"))
      end

      it "redirects to the posts path with status see_other" do
        delete :destroy, params: { id: post.id }
        expect(response).to redirect_to(posts_path)
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "GET #feed" do
    let!(:current_user) { create(:user) }
    let!(:test_user) { create(:user) }
    let!(:current_user_post) { create(:post, user: current_user) }
    let!(:followed_user_post) { create(:post, user: test_user) }
    let!(:non_followed_user) { create(:user) }
    let!(:non_followed_user_post) { create(:post, user: non_followed_user) }
    before do 
      log_in current_user
      current_user.follow(test_user)
      get :feed
    end

    it "assigns @post_items with posts from followed users and current user" do
      post_items = assigns(:post_items)
      expected_posts = [current_user_post, followed_user_post]
      expect(post_items).to match_array(expected_posts)
    end

    it "does not include posts from non-followed users" do
      expect(assigns(:post_items)).not_to include(non_followed_user_post)
    end

    it "paginates @post_items" do
      pagy, post_items = assigns(:pagy), assigns(:post_items)
      expect(pagy).to be_a(Pagy)
      expect(post_items.size).to be <= Settings.posts.per_page
    end
  end
end
