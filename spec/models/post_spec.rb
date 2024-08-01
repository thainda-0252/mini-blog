require "rails_helper"

RSpec.describe Post, type: :model do
  describe "enums" do
    it { should define_enum_for(:status).with_values(published: 1, unpublished: 0) }
  end

  describe "validations" do
    it { should validate_presence_of(:caption) }
    it { should validate_length_of(:caption).is_at_most(Settings.posts.max_caption) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_one_attached(:content_url) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:liked_users).through(:likes).source(:user) }
  end

  describe "delegations" do
    it { should delegate_method(:username).to(:user) }
  end

  describe "scopes" do
    describe ".newest" do
      let(:user) { create(:user) }
      let!(:post_1) { create(:post, created_at: 2.days.ago, user: user) }
      let!(:post_2) { create(:post, created_at: 1.day.ago, user: user) }
      let!(:post_3) { create(:post, created_at: 3.days.ago, user: user) }
    
      it "orders by created_at descending" do
        expect(Post.newest.pluck(:id)).to eq([post_2.id, post_1.id, post_3.id])
      end
    end
  end
end
