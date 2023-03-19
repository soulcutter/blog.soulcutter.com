module SiteBuilder
  class MarkdownAsset < Asset
    private def markdown_page = Components::MarkdownPage.new(read)

    def write(destination)
      FileUtils.mkdir_p(File.dirname(destination))

      File.write(
        destination,
        markdown_page.call(view_context: {current_page: slug})
      )
    end

    def slug
      File.join(
        path.delete_suffix(".md").delete_suffix("/index").gsub(/\d{4}-\d{2}-\d{2}-/, "").tr("_", "-"),
        "index.html"
      )
    end

    # TODO: should memoize this
    def metadata = markdown_page.data
  end
end
