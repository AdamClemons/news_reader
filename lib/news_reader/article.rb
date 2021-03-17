class NewsReader::Article
    attr_accessor :url, :title, :source, :author, :date, :mins, :body, :section, 
    :downloaded

    def initialize(section, title_url_hash)
        @section = section
        @title = title_url_hash[:title]
        @url = title_url_hash[:url]
        @downloaded = false 
        
        section.add_article(self)
    end


    def fetch_content
        if !body
            NewsReader::Scraper.scrape_article(self)
        end
    end

end