class NewsReader::CLI

    def call
        puts "\n-------------------------------------------------------------------------------"
        puts "\nWelcome to News Reader\n"
        choose_section
    
    end

    def choose_section
        puts "\n-------------------------------------------------------------------------------"
        puts "Choose a Section to Continue\n\n"
        display_sections
        puts "\nNavigate:"
        puts "#{NewsReader::Section.all.length + 1}. Enter Offline Viewing Mode"
        puts "#{NewsReader::Section.all.length + 2}. Exit News Reader"
       
        input = make_selection(NewsReader::Section.all.length + 2)

        if input == NewsReader::Section.all.length + 1
            offline_viewing_mode
        elsif input == NewsReader::Section.all.length + 2
            exit
        else
            section_choice = NewsReader::Section.all[input - 1]
            choose_article(section_choice)
        end
    end

    def display_sections
        NewsReader::Section.fetch_sections
        NewsReader::Section.all.each_with_index {|section, i| puts("#{i+1}. #{section.name}")}
    end

    def choose_article(section)
        section.fetch_articles        
        list_articles(section)
        puts "\nNavigate:"
        puts "#{section.articles.length + 1}. Choose Another Section"
        puts "#{section.articles.length + 2}. Exit News Reader"

        article_input = make_selection(section.articles.length + 2)

        if article_input == section.articles.length + 1
            choose_section
        elsif article_input == section.articles.length + 2
            exit
        else
            article_choice = section.articles[article_input - 1]
            article_choice.fetch_content
            read_article(article_choice)
        end
    end

    def list_articles(section)
        puts "\n-------------------------------------------------------------------------------"
        puts "#{section.name}"
        puts "Choose an Article to be displayed"
        puts "\nArticles:"
        
        section.articles.each_with_index do |article, i| 
            puts("#{i+1}. #{article.title}")
        end        
    end

    def read_article(article)
        display_article(article)
        puts "\nNavigate:"
        puts "1. Return to #{article.section.name} Articles"
        puts "2. Choose a new section"
        puts "3. Exit News Reader"
        
        input = make_selection(3)

        if input == 1
            choose_article(article.section)
        elsif input == 2
            choose_section
        else
            exit
        end
    end

    def display_article(article)
        puts "\n-------------------------------------------------------------------------------"
        puts article.source if article.source
        puts article.title
        puts "\n"
        puts article.author if article.author
        puts article.date if article.date
        puts "---------------------------------"
        puts article.body

        puts "-------------------------------------------------------------------------------"
    end

    def exit
        puts "\nThank you for choosing News Reader.\n\n"
    end

    def make_selection(range)
        puts "\nMake a Selection Below:"
        input = gets.to_i
        until input.between?(1, range)
            puts "Please make a valid selection:"
            input = gets.to_i
        end 
        input
    end




# Offline Viewing Mode Methods

    def offline_viewing_mode
        puts "\n-------------------------------------------------------------------------------"
        puts "Offline Viewing Mode - Main Menu\n\n"
        puts "1. View articles downloaded"
        puts "2. Download Section for offline viewing"
        puts "3. Download All News (takes a moment)"
        puts "4. Leave Offline Viewing Mode"
        puts "5. Exit News Reader"

        input = make_selection(4)

        case input
        when 1
            view_articles_downloaded
        when 2
            download_section
        when 3
            download_all
        when 4
            choose_section
        when 5
            exit
        end

    end

    def view_articles_downloaded
        puts "\n-------------------------------------------------------------------------------"
        puts "Offline Viewing Mode - Downloaded Articles"
        downloaded_in_order = []
        counter = 0

        NewsReader::Section.all.each do |section|
            if(section.articles.detect {|article| article.downloaded == true})
                puts "---------------------------------\n\n"
                puts section.name
                puts "\n"
                section.articles.each do |article|
                    if article.downloaded == true
                        counter += 1
                        puts "#{counter}. #{article.title}"
                        downloaded_in_order << article
                    end

                end
            end
        end
        puts "---------------------------------\n\n"
        offline_menu(NewsReader::Article.downloaded.length) do |input|
            read_offline_article(downloaded_in_order[input - 1])
        end
    end

    def read_offline_article(article)
        display_article(article)
        offline_menu(0)
    end

    def download_section
        puts "\n-------------------------------------------------------------------------------"
        puts "Offline Viewing Mode - Choose Section for Download\n\n"
        display_sections

        offline_menu(NewsReader::Section.all.length) do |input|
            section = NewsReader::Section.all[input - 1]
            section.fetch_articles
            section.articles.each {|article| article.fetch_content}
            view_articles_downloaded
        end
    end

    def download_all
        NewsReader::Section.all.each do |section|
            section.fetch_articles
            section.articles.each {|article| article.fetch_content}
        end
        view_articles_downloaded 
    end

    def offline_menu(items)
        puts "\nNavigate:"
        puts "#{items + 1}. Offline Viewing Mode - Main Menu"
        puts "#{items + 2}. View Articles Downloaded"
        puts "#{items + 3}. Leave Offline Viewing Mode"
        puts "#{items + 4}. Exit News Reader"

        input = make_selection(items + 4)

        case input
        when items + 1
            offline_viewing_mode
        when items + 2
            view_articles_downloaded
        when items + 3
            choose_section
        when items + 4
            exit
        else
            yield(input)
        end
    end 

end