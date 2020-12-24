require 'nokogiri'
require 'date'

class RssGenerator
  def initialize(courses)
    @courses = courses
  end

  def rss
    builder.to_xml
  end

  private

  attr_reader :courses

  def builder
    # @builder ||= Nokogiri::XML::Builder.new do |xml|
    Nokogiri::XML::Builder.new do |xml|
      xml.rss(rss_attributes) do
        xml.channel do
          xml.description 'RSS Feed of audio from Open Yale Courses'
          xml.image do
            xml.url 'https://zfletch.github.io/yale-courses-rss/logo.png'
            xml.title 'Open Yale Courses RSS'
            xml.link 'https://zfletch.github.io/yale-courses-rss/'
          end
          xml.language 'en-us'
          xml.lastBuildDate Time.now
          xml.link 'https://zfletch.github.io/yale-courses-rss/rss.xml'
          xml.title 'Open Yale Courses RSS'
          xml[:itunes].author 'Open Yale Courses'
          xml[:itunes].explicit 'no'
          xml[:itunes].image 'https://zfletch.github.io/yale-courses-rss/logo.png'
          xml[:itunes].owner do
            xml[:itunes].name 'Zachary Fletcher'
            xml[:itunes].email 'open.yale.courses.rss@gmail.com'
          end
          xml[:itunes].summary 'RSS Feed of audio from Open Yale Courses'
          items(xml)
        end
      end
    end
  end

  def rss_attributes
    {
      'xmlns:itunes': 'http://www.itunes.com/dtds/podcast-1.0.dtd',
      version: '2.0',
    }
  end

  def items(xml)
    courses.each do |course|
      start_date = Date.parse(course[:start_date])

      course[:lectures].each.with_index do |lecture, ii|
        next unless lecture[:mp3_path]

        xml.item do
          xml.title "#{course[:course_number]}: #{lecture[:shortname]}"
          xml.description "#{course[:course_title]}: #{lecture[:name]}"
          xml[:itunes].summary "#{course[:course_title]}: #{lecture[:name]}"
          xml.link lecture[:link]
          xml.enclosure(url: lecture[:mp3_path], type: 'audio/mpeg', length: lecture[:length])
          xml.pubDate(start_date + ii)
          xml[:itunes].author course[:professor]
          xml[:itunes].duration duration_string(lecture[:duration])
          xml[:itunes].explicit 'no'
          xml.guid lecture[:link]
        end
      end
    end
  end

  def duration_string(duration)
    hours = duration / 60 / 60
    minutes = 60 * (hours - hours.to_i)
    seconds = 60 * (minutes - minutes.to_i)

    "#{numeric_string(hours)}:#{numeric_string(minutes)}:#{numeric_string(seconds)}"
  end

  def numeric_string(number)
    number.to_i.to_s.rjust(2, '0')
  end
end
