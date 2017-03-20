require "integration_test_helper"

class UnpublishTest < ActionDispatch::IntegrationTest
  setup do
    @artefact = FactoryGirl.create(:artefact,
       slug: "bertie-botts-every-flavour-beans",
       kind: "answer",
       name: "Bertie Bott's Every Flavour Beans",
       owning_app: "publisher")

    @edition = FactoryGirl.create(:answer_edition,
                                   panopticon_id: @artefact.id,
                                   body: "They're quite gross.")
    setup_users
    stub_linkables
  end

  should "unpublishing an artefact archives all editions" do
    visit "/editions/#{@edition.id}"

    select_tab "Unpublish"

    UnpublishService.expects(:call).with(@artefact, User.first, '').returns(true)

    click_button "Unpublish"

    assert current_url, root_path

    within(".alert-success") do
      assert page.has_content?("Content unpublished")
    end

    @artefact.update(state: 'archived')

    visit "/editions/#{@edition.id}"

    within(".callout-danger") do
      assert page.has_content?("You can’t edit this publication")
      assert page.has_content?("This publication’s artefact file has been archived")
    end
  end

  context "when redirecting a piece of content" do
    should "display a confirmation message when redirected successfully" do
      visit "editions/#{@edition.id}"

      select_tab "Unpublish"

      fill_in 'redirect_url', with: 'https://gov.uk/beans'

      UnpublishService.expects(:call).with(@artefact, User.first, '/beans').returns(true)

      click_button "Unpublish"

      assert current_url, root_path

      within(".alert-success") do
        assert page.has_content?("Content unpublished and redirected")
      end
    end

    should "show an error when using an external redirect" do
      visit "editions/#{@edition.id}/unpublish"

      fill_in "redirect_url", with: "https://www.example.com/bar"

      click_button "Unpublish"

      assert_selector ".alert-danger"
      assert page.has_content?("Redirect URL is not a valid redirect target")
    end
  end
end
