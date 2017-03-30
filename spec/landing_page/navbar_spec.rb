# edited by app gen (landing page)

RSpec.describe 'Landing page nav bar', type: :request do
  before { visit root_path }

  describe 'Nav bar' do
    describe 'Header' do
      specify do
        within :css, 'div.navbar-header' do
          expect(page).to have_text AppName::REGEXP
        end
      end
    end

    describe 'Items' do
      specify do
        within :css, 'ul.nav.navbar-nav' do
          expect(page).to have_text(
            'About Products Services More Info Log In Sign Up'
          )
        end
      end
    end
  end
end
