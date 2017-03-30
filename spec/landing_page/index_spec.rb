# edited by app gen (landing page)

# rubocop:disable Metrics/BlockLength

RSpec.describe 'Landing page', type: :request do
  before { visit root_path }

  let(:name_re) { AppName::REGEXP }

  describe 'Header' do
    specify do
      within :css, 'header' do
        expect(page).to have_text name_re
      end
    end
  end

  describe 'About' do
    specify do
      within :css, 'section#about' do
        expect(page).to have_text name_re
      end
    end
  end

  describe 'Services' do
    specify do
      within :css, 'section#services' do
        expect(page).to have_text(/services/i)
      end
    end
  end

  describe 'More Info' do
    [
      /Contact/i,
      %r{HQ \s+ Address/Map}x,
      /Copyright .+? #{AppName::REGEXP_STRING} \s+ #{Time.zone.now.year}/x
    ].each do |text|
      specify do
        within :css, 'footer#more_info' do
          expect(page).to have_text text
        end
      end
    end
  end
end
