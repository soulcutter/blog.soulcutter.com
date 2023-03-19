module SiteBuilder
  class MarkdownAsset < Asset
    def write(destination)
      FileUtils.mkdir_p(File.dirname(destination))

      File.write(
        destination,
        Components::MarkdownPage.new(read).call(view_context: {current_page: slug})
      )
    end

    def slug
      File.join(
        path.delete_suffix(".md").delete_suffix("/index").gsub(/\d{4}-\d{2}-\d{2}-/, "").tr("_", "-"),
        "index.html"
      )
    end
  end
end
