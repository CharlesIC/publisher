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
  end

  def result
    subject.render_for_publishing_api
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
end