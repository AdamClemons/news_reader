class CLI

    def call
        puts "\n-------------------------------------------------------------------------------"
        puts "\nWelcome to News Reader\nChoose a Section to get started"
        choose_section
    
    end

    
    def choose_section
        NewsReader::Section.fetch_sections
        puts "\n-------------------------------------------------------------------------------"
        puts "Sections:"
        NewsReader::Section.all.each_with_index {|section, i| puts("#{i+1}. #{section.name}")}
        puts "\nNavigate:"
        puts "#{NewsReader::Section.all.length + 1}. Exit News Reader"
       
        input = make_selection(NewsReader::Section.all.length + 1)

        if input == NewsReader::Section.all.length + 1
            exit
        else
            section_choice = NewsReader::Section.all[input - 1]
            choose_article(section_choice)
        end
    end
    
    def choose_article(section)
        section.fetch_articles        
        puts "\n-------------------------------------------------------------------------------"
        puts "#{section.name}"
        puts "Choose an Article to be displayed"
        puts "\nArticles:"
        
        section.articles.each_with_index do |article, i| 
            puts("#{i+1}. #{article.title}")
        end
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
            display_article(article_choice)
        end

    end

    def display_article(article)
        puts "\n-------------------------------------------------------------------------------"
        puts article.source if article.source.length > 0
        puts article.title
        puts "\n"
        puts article.author if article.author.length > 0
        puts article.date if article.date.length > 0
        puts "---------------------------------"
        puts article.body

        puts "-------------------------------------------------------------------------------"
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


end