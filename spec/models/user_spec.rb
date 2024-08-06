require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

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
end
