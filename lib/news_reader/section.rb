class NewsReader::Section 

    attr_accessor :name, :url

    @@all = []

    def initialize(section_hash)
        @articles = []
        section_hash.each {|key, value| self.send("#{key}=", value)}
        @@all << self
    end

    def self.all
        @@all        
    end

    def add_article(article)
        raise "invalid article" if !article.is_a?(Article)
        @articles << article
    end

    def articles
        @articles.dup.freeze
    end


    def self.fetch_sections
        if self.all.empty?
            home_url = "https://news.yahoo.com/"
            sections = Scraper.scrape_sections(home_url)
        end
    end

    def fetch_articles
        Scraper.scrape_section_page(self) if articles.empty? 
    end

end


