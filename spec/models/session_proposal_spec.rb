require "rails_helper"

RSpec.describe SessionProposal, :type => :model do
  let(:session_proposal) { FactoryGirl.build(:session_proposal) }

  describe "attributes" do
    it { expect(SessionProposal.attribute_names).to include 'user_id' }
    it { expect(SessionProposal.attribute_names).to include 'title' }
    it { expect(SessionProposal.attribute_names).to include 'description' }
  end

  describe "#autosave_associated_records_for_tags" do
    it "should create tag if it doesn't exist" do
      session_proposal.tags << FactoryGirl.build(:tag)
      expect { session_proposal.save! }.to change(Tag, :count).by(1)
    end

    it "should not create tag if it exists" do
      tag = FactoryGirl.create(:tag)
      session_proposal.tags << tag
      expect { session_proposal.save! }.to change(Tag, :count).by(0)
    end
  end

  describe "#as_indexed_json" do
    it { expect(session_proposal.as_indexed_json['title']).to eq session_proposal.title }
    it { expect(session_proposal.as_indexed_json['author']).to eq session_proposal.user.full_name }
    it "should include tags name" do
      session_proposal.tags << FactoryGirl.create(:tag) << FactoryGirl.create(:tag, name: 'scrum')
      expect(session_proposal.as_indexed_json['tags']).to eq %w[xp scrum]
    end
  end
end