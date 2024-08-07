require "rails_helper"
include SessionsHelper

RSpec.describe UsersController, type: :controller do
  let!(:users) { create_list(:user, 20) }

  before do
    log_in users.first
  end

  RSpec.shared_examples "when user is not found" do
    before do
      get :liked_posts, params: { id: -1 }
    end

    it "sets a flash danger message" do
      expect(flash[:danger]).to eq(I18n.t("user.not_found"))
    end

    it "redirects to the root path" do
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @users and @user_items" do
      get :index
      expect(assigns(:users)).to match_array(users)
      expect(assigns(:user_items)).to match_array(users.first(Settings.users.per_page))
    end

    it "paginates the users" do
      get :index
      pagy, user_items = assigns(:pagy), assigns(:user_items)
      expect(pagy).to be_a(Pagy)
      expect(user_items.size).to eq(Settings.users.per_page)
    end
  end

  describe "GET #new" do
    it "assigns a new User to @user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end

    it "returns a 200 status code" do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    let(:valid_params) { attributes_for(:user) }
    let(:invalid_params) { attributes_for(:user, username: "") }

    context "with valid attributes" do
      it "creates a new user" do
        expect {
          post :create, params: { user: valid_params }
        }.to change(User, :count).by(1)
      end

      it "resets the session" do
        expect(controller).to receive(:reset_session)
        post :create, params: { user: valid_params }
      end

      it "logs in the user" do
        post :create, params: { user: valid_params }
        expect(session[:user_id]).to eq(User.last.id)
      end

      it "sets the success flash message" do
        post :create, params: { user: valid_params }
        expect(flash[:success]).to eq(I18n.t("users.create.success"))
      end

      it "redirects to root path" do
        post :create, params: { user: valid_params }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid attributes" do
      it "does not create a new user" do
        expect {
          post :create, params: { user: invalid_params }
        }.not_to change(User, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post :create, params: { user: invalid_params }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #show" do
    let!(:user) { create(:user) }
    let!(:post1) { create(:post, user: user, created_at: 1.day.ago) }
    let!(:post2) { create(:post, user: user, created_at: 2.days.ago) }

    context "when user is found" do
      before do
        get :show, params: { id: user.id }
      end

      it "assigns the requested user to @user" do
        expect(assigns(:user)).to eq(user)
      end

      it "assigns the user's posts to @post_items ordered by newest" do
        expect(assigns(:post_items)).to eq([post1, post2])
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when user is not found" do
      include_examples "when user is not found"
    end
  end

  describe "GET #liked_posts" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:liked_post1) { create(:post, user: other_user) }
    let!(:liked_post2) { create(:post, user: other_user) }

    before do
      user.like(liked_post1)
      user.like(liked_post2)
    end

    context "when user is found" do
      before do
        get :liked_posts, params: { id: user.id }, format: :turbo_stream
      end

      it "assigns the requested user to @user" do
        expect(assigns(:user)).to eq(user)
      end

      it "assigns the user's liked posts to @post_items ordered by newest" do
        expect(assigns(:post_items)).to eq([liked_post2, liked_post1])
      end

      it "renders the posts_list partial" do
        expect(response).to render_template(partial: '_posts_list')
      end
    end

    context "when user is not found" do
      include_examples "when user is not found"
    end
  end
end
