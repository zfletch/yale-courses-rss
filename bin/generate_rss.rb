#!/usr/bin/env ruby

require 'json'
require_relative '../lib/rss_generator'

file = File.read('courses.json')
json = JSON.parse(file, symbolize_names: true)

puts(RssGenerator.new(json).rss)
