#!/usr/bin/env ruby
#
# Populates page.posts for tab pages that use layout: category.
# _tabs/ is a Jekyll collection, not a pages directory, so we iterate
# site.collections['tabs'].docs instead of site.pages.

module Jekyll
  class CategoryTabPopulator < Generator
    safe true
    priority :low

    def generate(site)
      tabs = site.collections['tabs']
      return unless tabs

      tabs.docs.each do |page|
        next unless page.data['layout'] == 'category'

        # Support both singular 'category' and plural 'categories' in front matter
        category = page.data['category'] || page.data['categories']
        next unless category

        # Normalize to string
        category = category.first if category.is_a?(Array)
        category = category.to_s.strip

        matched = site.posts.docs.select do |post|
          cats = post.data['categories']
          cats = [cats] if cats.is_a?(String)
          cats = [] if cats.nil?
          cats.map(&:to_s).include?(category)
        end

        page.data['posts'] = matched.sort_by { |p| p.date }.reverse
        Jekyll.logger.info "CategoryTabPopulator:", "Tab '#{page.data['title']}' matched #{matched.size} posts for category '#{category}'"
      end
    end
  end
end
