class NewsReader::Article
    attr_accessor :url, :title, :source, :author, :date, :mins, :body, :section

    
    def initialize(section, title_url_hash)
        @section = section
        @title = title_url_hash[:title]
        @url = title_url_hash[:url]

        section.add_article(self)
    end
    
    def fetch_content
        NewsReader::Scraper.scrape_article(self) if !body   
    end

end