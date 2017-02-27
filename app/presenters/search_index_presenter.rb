class SearchIndexPresenter
  extend Forwardable

  def_delegators :@edition,
    :slug,
    :title,
    :artefact,
    :indexable_content,
    :latest_change_note,
    :format

  def initialize(edition)
    @edition = edition
  end

  def state
    case @edition.state
    when 'published' then 'live'
    when 'archived' then 'archived'
    else 'draft'
    end
  end

  def description
    @edition.overview
  end

  def paths
    case @edition.class
    when TransactionEdition, CampaignEdition, HelpPageEdition
      ["/#{@edition.slug}", "/#{@edition.slug}.json"]
    else
      ["/#{@edition.slug}.json"]
    end
  end

  def prefixes
    case @edition.class
    when TransactionEdition, CampaignEdition, HelpPageEdition
      []
    else
      ["/#{@edition.slug}"]
    end
  end

  def public_timestamp
    @edition.public_updated_at
  end
end
