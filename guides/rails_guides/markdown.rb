# frozen_string_literal: true

require "redcarpet"
require "nokogiri"
require "rails_guides/markdown/renderer"
require "rails_guides/markdown/epub_renderer"
require "rails-html-sanitizer"

module RailsGuides
  class Markdown
    def initialize(view:, layout:, edge:, version:, epub:)
      @view          = view
      @layout        = layout
      @edge          = edge
      @version       = version
      @index_counter = Hash.new(0)
      @raw_header    = ""
      @node_ids      = {}
      @epub          = epub
    end

    def render(body)
      @raw_body = body
      extract_raw_header_and_body
      generate_header
      generate_description
      generate_title
      generate_body
      generate_structure
      generate_index
      render_page
    end

    private
      def dom_id(nodes)
        dom_id = dom_id_text(nodes.last.text)

        # Fix duplicate node by prefix with its parent node
        if @node_ids[dom_id]
          if @node_ids[dom_id].size > 1
            duplicate_nodes = @node_ids.delete(dom_id)
            new_node_id = "#{duplicate_nodes[-2][:id]}-#{duplicate_nodes.last[:id]}"
            duplicate_nodes.last[:id] = new_node_id
            @node_ids[new_node_id] = duplicate_nodes
          end

          dom_id = "#{nodes[-2][:id]}-#{dom_id}"
        end

        @node_ids[dom_id] = nodes
        dom_id
      end

      def dom_id_text(text)
        escaped_chars = Regexp.escape('\\/`*_{}[]()#+-.!:,;|&<>^~=\'"')

        text.downcase.gsub(/\?/, "-questionmark")
                     .gsub(/!/, "-bang")
                     .gsub(/[#{escaped_chars}]+/, " ").strip
                     .gsub(/\s+/, "-")
      end

      def engine
        renderer = @epub ? EpubRenderer : Renderer
        @engine ||= Redcarpet::Markdown.new(renderer,
          no_intra_emphasis: true,
          fenced_code_blocks: true,
          autolink: true,
          strikethrough: true,
          superscript: true,
          tables: true
        )
      end

      def extract_raw_header_and_body
        if /^-{40,}$/.match?(@raw_body)
          @raw_header, _, @raw_body = @raw_body.partition(/^-{40,}$/).map(&:strip)
        end
      end

      def generate_body
        @body = engine.render(@raw_body)
      end

      def generate_header
        @header = engine.render(@raw_header).html_safe
      end

      def generate_description
        sanitizer = Rails::Html::FullSanitizer.new
        @description = sanitizer.sanitize(@header).squish
      end

      def generate_structure
        @headings_for_index = []
        if @body.present?
          document = html_fragment(@body).tap do |doc|
            hierarchy = []

            doc.children.each do |node|
              if /^h[2-5]$/.match?(node.name)
                case node.name
                when "h2"
                  hierarchy = [node]
                  @headings_for_index << [1, node, node.inner_html]
                when "h3"
                  hierarchy = hierarchy[0, 1] + [node]
                  @headings_for_index << [2, node, node.inner_html]
                when "h4"
                  hierarchy = hierarchy[0, 2] + [node]
                when "h5"
                  hierarchy = hierarchy[0, 3] + [node]
                end

                node[:id] = dom_id(hierarchy) unless node[:id]
                node.inner_html = "#{node_index(hierarchy)} #{node.inner_html}"
              end
            end

            doc.css("h2, h3, h4, h5").each do |node|
              node.inner_html = "<a class='anchorlink' href='##{node[:id]}'>#{node.inner_html}</a>"
            end
          end
          @body = @epub ? document.to_xhtml : document.to_html
        end
      end

      def generate_index
        if @headings_for_index.present?
          raw_index = ""
          @headings_for_index.each do |level, node, label|
            if level == 1
              raw_index += "1. [#{label}](##{node[:id]})\n"
            elsif level == 2
              raw_index += "    * [#{label}](##{node[:id]})\n"
            end
          end

          @index = html_fragment(engine.render(raw_index)).tap do |doc|
            doc.at("ol")[:class] = "chapters"
            doc.at("ol")['data-turbo'] = "false"
          end.to_html

          @index = <<-INDEX.html_safe
          <div id="subCol">
            <h3 class="chapter"><img src="images/chapters_icon.gif" alt="" />Chapters</h3>
            #{@index}
          </div>
          INDEX
        end
      end

      def generate_title
        if heading = html_fragment(@header).at(:h1)
          @title = "#{heading.text} — Ruby on Rails Guides"
        else
          @title = "Ruby on Rails Guides"
        end
      end

      def node_index(hierarchy)
        case hierarchy.size
        when 1
          @index_counter[2] = @index_counter[3] = @index_counter[4] = 0
          "#{@index_counter[1] += 1}"
        when 2
          @index_counter[3] = @index_counter[4] = 0
          "#{@index_counter[1]}.#{@index_counter[2] += 1}"
        when 3
          @index_counter[4] = 0
          "#{@index_counter[1]}.#{@index_counter[2]}.#{@index_counter[3] += 1}"
        when 4
          "#{@index_counter[1]}.#{@index_counter[2]}.#{@index_counter[3]}.#{@index_counter[4] += 1}"
        end
      end

      def render_page
        @view.content_for(:header_section) { @header }
        @view.content_for(:description) { @description }
        @view.content_for(:page_title) { @title }
        @view.content_for(:index_section) { @index }
        @view.render(layout: @layout, html: @body.html_safe)
      end

      def html_fragment(html)
        if defined?(Nokogiri::HTML5)
          Nokogiri::HTML5.fragment(html)
        else
          Nokogiri::HTML4.fragment(html)
        end
      end
  end
end
