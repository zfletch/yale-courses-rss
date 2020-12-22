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
    memo[path] ||= Nokogiri::HTML(HTTParty::get("#{base}#{path}"))
  end

  def courses
    get(courses_path).css('table.views-table tbody tr').map do |row|
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
        lectures: lectures(link),
      }
    end
  end

  def lectures(link)
    get(link).css('div#quicktabs-tabpage-course-2 table.views-table tbody tr').map do |row|
      shortname, name = *row.css('td')

      link = name.css('a').first['href']

      {
        shortname: shortname.text.strip,
        name: name.text.strip,
        mp3_path: mp3_path(link),
      }
    end
  end

  def mp3_path(link)
    mp3 = get(link).css('td.views-field-field-audio--file a')
 
    mp3.size > 0 ? mp3.first['href'] : nil
  end
end
