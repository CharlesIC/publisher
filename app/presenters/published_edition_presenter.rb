class PublishedEditionPresenter
  def initialize(edition)
    @edition = edition
    @artefact = edition.artefact
  end

  def render_for_publishing_api(options={})
    {
      title: @edition.title,
      base_path: base_path,
      description: @edition.overview || "",
      schema_name: "placeholder",
      document_type: @artefact.kind,
      need_ids: [],
      public_updated_at: public_updated_at,
      publishing_app: "publisher",
      rendering_app: "frontend",
      routes: [
        {path: base_path, type: "exact"}
      ],
      redirects: [],
      update_type: update_type(options),
      details: {
        change_note: @edition.latest_change_note,
        external_related_links: external_related_links,
      },
      locale: @artefact.language,
    }
  end

private

  def external_related_links
    @edition.artefact.external_links.map do |link|
      {
        "url": link["url"],
        "title": link["title"]
      }
    end
  end

  def base_path
    "/#{@edition.slug}"
  end

  def update_type(options)
    if options[:republish]
      "republish"
    elsif major_change?
      "major"
    else
      "minor"
    end
  end

  def major_change?
    @edition.major_change || @edition.version_number == 1
  end

  def public_updated_at
    @edition.public_updated_at || @edition.updated_at
  end
end
