require "json"
require "open-uri"
#scraping
require "nokogiri"

def scraping()
  start_page= 1
  end_page = 20
  titre = "Mathraining"
  subject = ARGV[0]
  filename = "Problem#{subject}.tex"
  link ="http://www.mathraining.be/subjects/#{subject}?page="
  data = []
  puts "---------------------------------------------------"
  puts "------ Lancement scrapping sujet #{subject} -------"
  puts "---------------------------------------------------"

  if File.file?(filename)
    File.delete(filename)
  end

  File.open(filename, "a") do |line|
    line.puts '\documentclass{article}
\usepackage[utf8]{inputenc}
\usepackage{amsmath, amssymb}
\def\textyen{{\setbox0=\hbox{Y}Y\kern-.97\wd0\vbox{\hrule height.1ex
width.98\wd0\kern.33ex\hrule height.1ex width.98\wd0\kern.45ex}}}
\usepackage[a4paper,top=3cm,bottom=2cm,left=3cm,right=3cm,marginparwidth=1.75cm]{geometry}'

  end


    start_page.upto(end_page) do |page|
      base = "#{link}#{page}"

      begin
      html_file = open(base,
        "Host"=> "mathraining.be",
        "User-Agent"=>"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:49.0) Gecko/20100101 Firefox/49.0",
        "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language"=>"en-US,en;q=0.5",
        "Accept-Encoding"=>"gzip, deflate",
        "Cookie"=>"_mathraining_session=clhqK0ZTVHUyMWdoUW1QUG5idmMvSGNWYzhwdHBBZXF3a3VXRW5SVmUzUENkVzRrK0djckpmeS9YR2pwR29abkkvdE1vVHpxa3hTV1VmRHl1Z0MwVWVrU3FPSHNVc1c5ZWJxclNsWGJlSFFWK2JyRnBISm0vbFdaZC90am96SzdMaGpjVmd6T0hOTnJqcXh0ZEx0ek9GK2daY3BEc0trTGhCMU5oL2J2NWxtQ3RreTBjclQ3eXZ5Q1MrcDcwTTI3LS1QdE9CdkJlU2JmY0JjYnlYbUp6Ukd3PT0%3D--e0c563bc9eca0ba283fe976ab70ddd6a16d79e3f; remember_token=To5sMXqQwNFuhFd3PU5CNA",
        "Connection"=> "keep-alive")


      html_doc = Nokogiri::HTML(html_file, nil, Encoding::UTF_8.to_s)

      if page == start_page
        File.open("HTMLCode.txt", "w") do |line|
          line.puts html_doc
        end

        titleLine = File.readlines("HTMLCode.txt").select { |line| line =~ /<title>/ }.join("")
        titleLine = titleLine.split("|")[1]
        titleLine = titleLine.split("<")[0]

        puts titleLine

        File.open( filename, "a" ) do |line|

          line.puts '\title{Problèmes du ' + titleLine + '}'
          line.puts '\author{Daniel Cortild}'

          line.puts '\begin{document}'
          line.puts '\maketitle'
        end
      end



      html_doc.search("td .tex2jax_ignore").each do |element|


        post = element.text.strip
        post = "Something  " + post

        if post.include? "[/hide]" post.split("[/hide]")[0...-1].join("")
          aphide = post.split("[/hide]")[-1]
          avhide = post.split("[hide]")[0]
          post = avhide + aphide
        end

        if post =~ /[\[\].]+Problème[\s]*[0-9]*/

          text = post.split(/[\[\].]+Problème[\s]/)[-1]

          text.gsub! ':-D', ''
          text.gsub! ':-P', ''
          text.gsub! ':-)', ''
          text.gsub! '  ', ' '
          text.gsub! '[b]', ''
          text.gsub! '[u]', ''
          text.gsub! '[i]', ''
          text.gsub! '[/b]', ''
          text.gsub! '[/u]', ''
          text.gsub! '[/i]', ''
          text.gsub! '¨', ''
          text.gsub! "//", ''
          text.gsub! '<', '<'
          text.gsub! '≥', '\ge'
          text.gsub! '−', '-'
          text.gsub! '&', 'et'
          text.gsub! 'ﬁ', 'fi'
          text.gsub! '’', "'"
          text.gsub! '′', "'"
          text.gsub! '°', '^\circ'
          text.gsub! '¥', '\textyen'
          text.gsub! '×', '\times'
          text.gsub! '«', '"'
          text.gsub! '»', '"'
          text.gsub! '(Cacher le code)', ''
          text.gsub! '\nparallel', '\not \parallel'
          text.gsub! '[/url]', ''

          while text.include? "[url="
            avlien = text.split("[url=")[0]
            apavlien = text.split("[url=")[1..-1].join("")
            aplien = apavlien.split("]")[1]
            text = avlien + aplien
          end

          number = text.split(" ")[0]
          number.gsub! ':', ''
          number.gsub! '$', ''

          if text.split(" ").size > 1
            text = text.split(" ")[1..-1].join(" ")
          end

          problem = ""
          source = ""

          first = text[0..4]
          if first.index("(") != nil
            source = text.split(")")[0]
            source += ")"
            if text.index(")") > 1
              problem = text.split(")")[1..-1].join(")")
            else
              problem = text.split( ")" )[1]
            end
          else
            problem = text
          end

          problem.gsub! '#', '\#'
          if problem[0] == ':'
            problem = problem.split("")[1..-1].join("")
          end


          source.gsub! '$', ''
          source.gsub! '{', ''
          source.gsub! '}', ''
          source.gsub! '^', ''
          source.gsub! ':', ''
          source.gsub! "source", "Source"
          source.gsub! "Source inconnue", ""
          source.gsub! "stage", "Stage"
          source.gsub! '#', '\#'

          if problem.index("Source") != nil
            source = problem.split("(")[-1]
            source = "(" + source
            problem = problem.split("(")[0...-1].join("(")
          end

          if problem.split(" ")[0] == "2001$"
            problem = problem.split(" ")[1..-1].join("")
            source += "2001"
          end

          source.gsub! 'Source', ''
          source.gsub! "( ", "("
          source.gsub! " )", ")"
          source.gsub! "()", ""
          number.gsub! '\star', "'"

          final = '\textbf{' + "Problème "  + number + " " + source + '} \newline ' + problem
          final = '\vbox{ ' + final + '\newline' + '}'

          File.open(filename, "a") do |line|
            line.puts final
          end
        end
      end
      rescue Exception => e
        puts e
      end
    end

    File.open(filename, "a") do |line|
      line.puts '\end{document}'
    end

    %x(pdflatex #{filename})
    File.delete("HTMLCode.txt")
    filename2 = filename.split(".")[0]
    File.delete(filename2 + ".tex")
    File.delete(filename2 + ".aux")
    File.delete(filename2 + ".log")
  end
scraping
