require 'http'
require 'nokogiri'

class Crawler
  def get_url(url)
    HTTP::get(url)
  end

  def get_links(url)
    response = get_url(url)
    document = Nokogiri::parse(response)
    document.css('a').map { |p| p['href'] }
  end
end