require 'test_helper'

class ServiceSignInTest < ActiveSupport::TestCase
  include GovukContentSchemaTestHelpers::TestUnit

  def subject
    Formats::ServiceSignInPresenter.new(@content)
  end

  def file_name
    "example.yaml"
  end

  def load_content_from_file(file_name)
    @content ||= YAML.load_file(Rails.root.join("lib", "service_sign_in", file_name)).deep_symbolize_keys
  end

  def setup
    load_content_from_file(file_name)
    @artefact ||= FactoryGirl.create(:artefact, kind: "transaction")
    @parent ||= FactoryGirl.create(
      :transaction_edition,
      panopticon_id: @artefact.id,
      slug: "log-in-file-self-assessment-tax-return"
    )
  end

  def parent_base_path
    "/log-in-file-self-assessment-tax-return"
  end

  def base_path
    "#{parent_base_path}/sign-in"
  end

  def result
    subject.render_for_publishing_api
  end

  should "be valid against schema" do
    assert_valid_against_schema(result, 'service_sign_in')
  end

  should "[:schema_name]" do
    assert_equal 'service_sign_in', result[:schema_name]
  end

  should "[:rendering_app]" do
    assert_equal 'government-frontend', result[:rendering_app]
  end

  should "[:publishing_app]" do
    assert_equal 'publisher', result[:publishing_app]
  end

  should "[:document_type]" do
    assert_equal 'service_sign_in', result[:document_type]
  end

  should "[:locale]" do
    assert_equal @content[:locale], result[:locale]
  end

  should "[:update_type]" do
    assert_equal @content[:update_type], result[:update_type]
  end

  should "[:change_note]" do
    assert_equal @content[:change_note], result[:change_note]
  end

  should "[:base_path]" do
    assert_equal base_path, result[:base_path]
  end

  should "[:routes]" do
    expected = [
      { path: base_path, type: "prefix" },
    ]
    assert_equal expected, result[:routes]
  end

  should "[:title]" do
    assert_equal @parent.title, result[:title]
  end

  should "[:description]" do
    assert_equal @parent.overview, result[:description]
  end


  context "[:public_updated_at]" do
    should "return current timestamp when update_type is 'major'" do
      Timecop.freeze do
        assert_equal DateTime.now.rfc3339, result[:public_updated_at]
      end
    end

    should "return public_updated_at from content-store when update_type is not 'major'" do
      Formats::ServiceSignInPresenter.stub :update_type, "minor" do
        content_store_has_item(parent_base_path)
        content_item = content_item_for_base_path(parent_base_path)
        assert_equal content_item["public_updated_at"], result[:public_updated_at]
      end
    end
  end
end
