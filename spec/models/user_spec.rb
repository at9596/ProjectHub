require 'rails_helper'

RSpec.describe User, type: :model do
   context "#Enum" do
    it { should define_enum_for(:role).with_values({  owner: 0, admin: 1, member: 2, viewer: 3 }) }
  end
  context " #validations" do
    it { should validate_presence_of(:name) }
  end
  context "#associations" do
    it { should belong_to(:organization).optional(true) }
    it { should have_many(:owned_projects).class_name("Project").with_foreign_key('owner_id').dependent(:nullify) }
    it { should have_many(:assigned_tasks).class_name(:Task).with_foreign_key(:assignee_id).dependent(:nullify) }
    it { should have_many(:project_memberships).dependent(:destroy) }

    it { should have_many(:member_projects).through(:project_memberships).source(:project) }

    it { should have_many(:comments).dependent(:destroy) }

    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  context "#devise" do
     subject(:user) { build(:user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }

    it { should respond_to(:confirmation_token) }
    it { should respond_to(:invitation_token) }
  end
end
