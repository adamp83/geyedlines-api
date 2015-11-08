require 'open-uri'

class Condition < ActiveRecord::Base

  NHSEVIDENCE_URL = "http://www.nice.org.uk/Search?q="

  # Look to see if there is a guideline available for this condition by scraping NHS evidence
  # If there is, return the title and URL
  def guideline
    url = NHSEVIDENCE_URL + ERB::Util.url_encode(name)
    html = open(url)
    html_doc = Nokogiri::HTML(html.read)
    html_doc.encoding = 'utf-8'

    gs = html_doc.css('h4 > a')

    if gs.length > 0
      e = gs.first
      return {title: e.text.squish, url: e.attributes["href"].value}
    else
      return nil
    end
  end
end
