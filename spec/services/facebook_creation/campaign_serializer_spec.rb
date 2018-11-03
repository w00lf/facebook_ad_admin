require 'rails_helper'

RSpec.describe FacebookCreation::CampaignSerializer do
  let(:attributes) {
    {
      "Objective" => "conversions",
      "Campaign Name" => "Test campaign"
    }
  }

  subject { described_class.new(attributes).as_json }

  it 'Transform name attribute' do
    is_expected.to include(name: attributes.fetch("Campaign Name"))
  end

  it 'Transform objective attribute' do
    is_expected.to include(objective: attributes.fetch("Objective").upcase)
  end
end
