require "rails_helper"

RSpec.describe User, type: :model do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:post) { create(:post) }

  describe "validations" do
    required_attributes = %i(username email password)

    context "when validating length of attributes" do
      it "validates length of username to be at most #{Settings.users.max_name} characters" do
        should validate_length_of(:username).is_at_most(Settings.users.max_name)
      end

      it "validates length of email to be at most #{Settings.users.max_email} characters" do
        should validate_length_of(:email).is_at_most(Settings.users.max_email)
      end
    end

    context "when validating uniqueness and presence" do
      it "validates uniqueness of email, case insensitive" do
        should validate_uniqueness_of(:email).case_insensitive
      end

      it "has secure password" do
        should have_secure_password
      end

      required_attributes.each do |attribute|
        it "validates presence of #{attribute}" do
          should validate_presence_of(attribute)
        end
      end
    end

    context "when validating password" do
      it "validates length of password to be at least #{Settings.users.min_password} characters" do
        should validate_length_of(:password).is_at_least(Settings.users.min_password)
      end

      it "validates format of password" do
        should allow_value("Vali234@").for(:password).with_message(I18n.t("user.valid_password"))
      end
    end
  end
  describe "associations" do
    it { should have_many(:posts).dependent(:destroy)}
    it { should have_many(:liked_posts).through(:likes).source(:post)}
    it { should have_many(:following).through(:active_follows).source(:followee)}
    it { should have_many(:followers).through(:passive_follows).source(:follower)}
  end

  describe "methods" do
    describe "#downcase_email!" do
      let(:user) { build(:user, email: email) }
  
      context "when email contains uppercase letters" do
        let(:email) { "Example@EMAIL.COM" }
  
        it "downcases the email" do
          user.send(:downcase_email!)
          expect(user.email).to eq("example@email.com")
        end
      end
  
      context "when email is already in lowercase" do
        let(:email) { "example@email.com" }
  
        it "does not change the email" do
          original_email = user.email
          user.send(:downcase_email!)
          expect(user.email).to eq(original_email)
        end
      end
  
      context "when email is empty" do
        let(:email) { "" }
  
        it "does not change the email" do
          user.send(:downcase_email!)
          expect(user.email).to eq("")
        end
      end
    end
  end

  describe ".digest" do
    let(:password) { "Aa@123456" }
    let(:cost) { BCrypt::Engine.cost }

    it "returns a hashed password with the correct cost" do
      # Mocking the cost setting to ensure we can test against it
      allow(BCrypt::Engine).to receive(:cost).and_return(cost)

      hash = User.digest(password)
      expect(BCrypt::Password.new(hash)).to be_a(BCrypt::Password)
      expect(hash).to match(/\A\$2a\$/)  # Check for valid bcrypt hash prefix
    end

    context "when min_cost is false" do
      before do
        allow(ActiveModel::SecurePassword).to receive(:min_cost).and_return(false)
      end

      it "uses the default cost for hashing" do
        hash = User.digest(password)
        expect(hash).to match(/\A\$2a\$#{cost}/)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns the correct list of attributes" do
      expected_attributes = %w(username email created_at)
      expect(User.ransackable_attributes).to match_array(expected_attributes)
    end
  end

  describe "#follow" do
    it "follows another user" do
      expect {
        user.follow(other_user)
      }.to change(user.following, :count).by(1)
      expect(user.following).to include(other_user)
    end

    it "does not follow self" do
      expect {
        user.follow(user)
      }.not_to change(user.following, :count)
    end
  end

  describe "#unfollow" do
    before { user.follow(other_user) }

    it "unfollows another user" do
      expect {
        user.unfollow(other_user)
      }.to change(user.following, :count).by(-1)
      expect(user.following).not_to include(other_user)
    end
  end

  describe "#following?" do
    it "returns true if following another user" do
      user.follow(other_user)
      expect(user.following?(other_user)).to be_truthy
    end

    it "returns false if not following another user" do
      expect(user.following?(other_user)).to be_falsey
    end
  end

  describe "#like" do
    it "likes a post" do
      expect {
        user.like(post)
      }.to change(user.likes, :count).by(1)
      expect(user.liked_posts).to include(post)
    end
  end

  describe "#unlike" do
    before { user.like(post) }

    it "unlikes a post" do
      expect {
        user.unlike(post)
      }.to change(user.likes, :count).by(-1)
      expect(user.liked_posts).not_to include(post)
    end
  end

  describe "#liked?" do
    it "returns true if liked a post" do
      user.like(post)
      expect(user.liked?(post)).to be_truthy
    end

    it "returns false if not liked a post" do
      expect(user.liked?(post)).to be_falsey
    end
  end
end
