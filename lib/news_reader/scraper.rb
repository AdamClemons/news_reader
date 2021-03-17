class NewsReader::Scraper

    ARTICLES_PER_SECTION = 10 # Number of articles per section to download

    def self.scrape_sections(home_url)
        html = open(home_url)
        page = Nokogiri::HTML(html)
    
        # The drop(2).first(5) is due to selecting the sections we want.
        # The first 2 sections are the homepage and a special COVID page
        # Both use non-standard formatting for their article placement, so
        # are skipped.  After the 7th section, there is non-text content
        # a Podcasts section and then Video sections, so the scraper
        # specifically targets sections 3-7.
        page.css('a.nr-applet-nav-item').drop(2).first(5).each do |area|
            section = {
                :name => area.text,
                :url => combine_url(home_url, area.attr('href'))
            }
            NewsReader::Section.new(section)
        end
    end

    def self.scrape_section_page(section)
        html = open(section.url)
        page = Nokogiri::HTML(html)
        
        page.css('h3').first(ARTICLES_PER_SECTION).each do |news|
            story = {
                :title => news.text,
                :url => combine_url(section.url, news.css('a').attr('href').value)
            }
            NewsReader::Article.new(section, story)
        end
    end

    # Method where article is updated within Scraper class
    def self.scrape_article(article)
        # binding.pry
        begin
            html = open(article.url)
            page = Nokogiri::HTML(html)
        rescue OpenURI::HTTPError
            article.body = "404 Error.  Please choose another article."
        else
            html = open(article.url)
            page = Nokogiri::HTML(html)

            author = page.css('div.caas-attr-meta').text # author, date, length
            date_and_mins = page.css('div.caas-attr-time-style').text # date, length

            author.slice!(date_and_mins) # removes date, length to leave only author

            if page.css('img.caas-img').attr('alt')
                source = page.css('img.caas-img').attr('alt').value
            else
                source = page.css('div.caas-logo a').text
            end

            article_hash = {
                :title => page.css('h1').text,
                :source => source,
                :author => author,
                :date => page.css('div.caas-attr-time-style time').text,
                :mins => page.css('div.caas-attr-time-style span').text,
                :body => fetch_body(page),
                :downloaded => true
            }

            article_hash.each {|key, value| article.send("#{key}=", value)}
        end       
    end

    def self.fetch_body(page)
        article = ""
        links = []

        page.css('div.caas-body p').each do |p|
            article.concat(p.text, "\n\n")
        end
        article
    end

    def self.combine_url(parent, child)
        if parent[-1] == "/" && child[0] == "/"
           "#{parent[0..-2]}#{child}"
        else
           "#{parent}#{child}"
        end
    end

end
