# frozen_string_literal: true

class PageBuilder
	def self.build_all
		FileUtils.mkdir_p("#{__dir__}/dist")

		# TODO fingerprint assets and expose asset lookup in view_context
		FileUtils.cp_r("#{__dir__}/assets", "#{__dir__}/dist")

		pages = Dir["#{__dir__}/pages/**/*.md"]
		pages.each { |page| new(page).call }
	end

	def initialize(page)
		@page = page
        @path = compute_path
        freeze
	end

	def call
		FileUtils.mkdir_p(directory)
		File.write(file, Components::Page.new(File.read(@page)).call(view_context: { current_page: @path }))
	end

	private

	def file
		"#{directory}/index.html"
	end

	def directory
		"#{__dir__}/dist#{@path}"
	end

	def compute_path
		real_path = @page.delete_prefix("#{__dir__}/pages/").delete_suffix(".md").tr("_", "-")
		if real_path == "index"
			"/"
		else
			"/#{real_path}/"
		end
	end
end