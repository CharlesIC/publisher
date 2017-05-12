module Formats
  class GuidePresenter < EditionFormatPresenter
  private

    def schema_name
      'guide'
    end

    def document_type
      'guide'
    end

    def rendering_app
      "government-frontend"
    end

    def details
      {
        parts: parts,
        external_related_links: external_related_links,
      }
    end

    def parts
      edition.parts.in_order.map do |part|
        {
          title: part.title.to_s,
          slug: part.slug.to_s,
          body: [
            {
              content_type: "text/govspeak",
              content: part.body.to_s,
            }
          ]
        }
      end
    end

    def routes
      super + edition.parts.in_order.map do |part|
        { path: "#{base_path}/#{part.slug}", type: 'exact' }
      end
    end
  end
end
