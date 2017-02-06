require 'services'

class PublishingAPIPublisher
  include Sidekiq::Worker

  def perform(edition_id, update_type = nil)
    edition = Edition.find(edition_id)
    content_id = edition.artefact.content_id

    Services.publishing_api.publish(
      content_id,
      update_type,
      locale: edition.artefact.language
    )
  end
end
