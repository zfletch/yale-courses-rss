# Open Yale Courses RSS

This repository has two functions:

1. It serves as the web page for the [Open Yale Courses RSS](https://zfletch.github.io/yale-courses-rss/) podcast feed.
2. It contains the code needed to generate `rss.xml`.

See the web page linked above for information about the podcast.
The remainder of this README is about how to use the code to (re)generate `rss.xml`.

## Requirements

* Ruby ~2.7
* FFmpeg ~4.3
* Curl ~7.64

## Setup

* `bundle install`

## Scrape the OYC pages

MP3s are downloaded to the `./audio/` directory in order to calculate
their size and runtime.
The total size of the downloaded MP3s is around 50G.
If you have a small drive, you can create a link from
your external drive to `./audio/` instead of using `mkdir`.

* `mkdir audio`

Generate a JSON file with information about the courses.

* `./bin/generate_course_json.rb > courses.json`

## Generate the RSS feed

* `./bin/generate_rss.rb > rss.xml`
