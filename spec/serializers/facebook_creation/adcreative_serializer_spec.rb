require 'rails_helper'

RSpec.describe FacebookCreation::AdcreativeSerializer do
  MAIN_ATTRIBUTES = [
    "Image",
    "Website URL",
    "Text",
    "Headline",
    "URL Parameters"
  ].freeze

  let(:attributes) {
    {
      "Image"=>"https://onaliternote.files.wordpress.com/2016/11/wp-1480230666843.jpg?crop",
      "Website URL"=>"http://ya.ru",
      "Text"=>"Test text",
      "Headline"=>"Text headline",
      "News Feed Link Description(optional)"=>"-",
      "Page Id" => '12345',
      'News Feed Link Description' => 'This is news feed',
      "URL Parameters"=>"Ad=1&d=20.10&utm_source=HDSDSW&utm_medium=4325365476"
    }
  }
  let(:result) {
    {
      object_story_spec: {
        page_id: '12345',
        link_data: {
          message: "Test text",
          link: "http://ya.ru",
          attachment_style: "link",
          caption: "",
          name: "Text headline",
          description: 'This is news feed',
          image_url: "https://onaliternote.files.wordpress.com/2016/11/wp-1480230666843.jpg?crop",
        }
      },
      object_type: "SHARE",
      url_tags: "Ad=1&d=20.10&utm_source=HDSDSW&utm_medium=4325365476"
    }
  }

  subject { described_class.new(attributes).as_json }

  it 'Returns formated result' do
    p subject
    is_expected.to eq(result)
  end

  MAIN_ATTRIBUTES.each do |attribute|
    it "Raises AdsetSerializerError on missing attribute #{attribute}" do
      expect {
        described_class.new(attributes.reject {|n| n == attribute }).as_json
      }.to raise_error(FacebookCreation::AdcreativeSerializer::AdcreativeSerializerError)
    end
  end
end
