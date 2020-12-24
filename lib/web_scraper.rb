require 'httparty'
require 'json'
require 'nokogiri'

class WebScraper
  def initialize(base = 'https://oyc.yale.edu', courses_path = '/courses?order=field_semester&sort=asc')
    @base = base
    @courses_path = courses_path
    @memo = {}
  end

  def json
    JSON.pretty_generate(courses)
  end

  private

  attr_reader :base, :courses_path, :memo

  def get(path)
    memo[path] ||= Nokogiri::HTML(HTTParty::get("#{base}#{path}").body)
  end

  # We need the size of the mp3 file for the enclosure tag
  # Unfortunately, the Yale server doesn't provide it
  # The easiest way is to download the file and then check the size
  def length(url, name)
    basepath = File.expand_path(File.dirname(File.dirname(__FILE__)))
    filename = "#{basepath}/audio/#{name}.mp3"

    if !File.exist?(filename)
      `curl '#{url}' > '#{filename}'`
    end

    File.size(filename)
  end

  # This method requires ffmpeg to get the duration of the file
  def duration(name)
    basepath = File.expand_path(File.dirname(File.dirname(__FILE__)))
    filename = "#{basepath}/audio/#{name}.mp3"

    `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 '#{filename}'`.to_f
  end

  def courses
    get(courses_path).css('table.views-table tbody tr').map.with_index do |row, ii|
      department, course_number, course_title, professor, date = *row.css('td')

      season, year = date.text.strip.split
      start_date = Date.parse("#{year}-#{season == 'Spring' ? '05' : '09'}-01")

      link = course_title.css('a').first['href']

      {
        department: department.text.strip,
        course_number: course_number.text.strip,
        course_title: course_title.text.strip,
        professor: professor.text.strip,
        start_date: start_date,
        lectures: lectures(link, ii),
      }
    end
  end

  def lectures(link, ii)
    get(link).css('div#quicktabs-tabpage-course-2 table.views-table tbody tr').map.with_index do |row, jj|
      shortname, name = *row.css('td')

      link = name.css('a').first['href']
      mp3 = mp3_path(link)

      {
        link: "#{base}#{link}",
        length: length(mp3, "#{ii}-#{jj}"),
        duration: duration("#{ii}-#{jj}"),
        mp3_path: mp3,
        name: name.text.strip,
        shortname: shortname.text.strip,
      }
    end
  end

  def mp3_path(link)
    mp3 = get(link).css('td.views-field-field-audio--file a')
 
    mp3.size > 0 ? mp3.first['href'] : nil
  end
end
