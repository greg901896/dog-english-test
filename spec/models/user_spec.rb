require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with username and password" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "is invalid without username" do
      user = build(:user, username: nil)
      expect(user).not_to be_valid
    end

    it "is invalid with duplicate username" do
      create(:user, username: "same")
      user = build(:user, username: "same")
      expect(user).not_to be_valid
    end

    it "is invalid with password shorter than 6 characters" do
      user = build(:user, password: "12345")
      expect(user).not_to be_valid
    end
  end

  describe "associations" do
    it "has many quiz_records" do
      expect(User.reflect_on_association(:quiz_records).macro).to eq(:has_many)
    end

    it "has many favorites" do
      expect(User.reflect_on_association(:favorites).macro).to eq(:has_many)
    end
  end
end
