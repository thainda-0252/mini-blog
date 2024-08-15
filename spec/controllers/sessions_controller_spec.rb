require "rails_helper"
include SessionsHelper

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user) }
  describe "GET #new" do
    it "render the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid credentials" do
      it "logs in the user and redirects to root path" do
        post :create, params: { session: { email: user.email, password: user.password} }
        expect(session[:user_id]).to eq(user.id)
        expect(flash[:success]).to eq(I18n.t("login.success"))
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid credentials" do
      it "does not log in the user and re-renders the new template" do
        post :create, params: { session: { email: user.email, password: "wrong_password" } }
        expect(session[:user_id]).to be_nil
        expect(flash.now[:danger]).to eq(I18n.t("login.failed"))
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      log_in(user)
    end

    it "logs out the user and redirects to root url" do
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_url)
      expect(response).to have_http_status(:see_other)
    end
  end
end
