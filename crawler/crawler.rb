require 'uri'
require 'http'
require 'nokogiri'

class Crawler
  DEFAULT_MAX_REDIRECTS = 3
  DEFAULT_TIMEOUT_IN_SECONDS = 5

  def initialize(seed_url, timeout: DEFAULT_TIMEOUT_IN_SECONDS, max_redirects: DEFAULT_MAX_REDIRECTS)
    @seed_uri = URI(seed_url)
    @timeout = timeout
    @max_redirects = max_redirects

    validate_params(seed_url, timeout, max_redirects)
  end

  def fetch_links(output_to: nil)
    links = extract_links(fetch_html())

    output(links, output_to) unless output_to.nil?

    links
  rescue HTTP::TimeoutError => e
    raise RequestTimeoutError.new("Timed out after #{@timeout} seconds")
  end

  def fetch_html
    response = HTTP::follow(max_hops: @max_redirects).timeout(@timeout).get(@seed_uri.to_s)
    raise_on_errors(response)
    response.to_s
  end

  private

  def validate_params(seed_url, timeout, max_redirects)
    raise InvalidParam.new("Invalid URL: #{seed_url}") unless @seed_uri.kind_of?(URI::HTTP) || @seed_uri.kind_of?(URI::HTTPS)
    raise InvalidParam.new("Invalid timeout: #{timeout}") unless timeout.is_a?(Integer)
    raise InvalidParam.new("Invalid max redirects: #{max_redirects}") unless max_redirects.is_a?(Integer)
  end

  def extract_links(html)
    hrefs = extract_hrefs(html)
    hrefs = reject_external(hrefs)
    hrefs = normalize_internal(hrefs)
  end

  def extract_hrefs(html)
    document = Nokogiri::HTML(html)

    links = document.css('a')

    hrefs = links.map {|a| a['href']}
    hrefs = hrefs.reject {|href| href.nil?}
  end

  def reject_external(hrefs)
    hrefs.select do |href|
      URI::parse(href).hostname == @seed_uri.hostname || href.start_with?('/')
    end
  end

  def normalize_internal(hrefs)
    hrefs.map do |href|
      if href.start_with?('//')
        next "#{@seed_uri.scheme}:#{href}"
      elsif href.start_with?('/')
        next base_url + href
      end

      href
    end
  end

  def output(links, destination)
    links.each {|link| destination.puts(link)}
    destination.flush
  end

  def base_url
    "#{@seed_uri.scheme}://#{@seed_uri.hostname}"
  end

  def raise_on_errors(response)
    if response.status.code == 404
      raise FetchError.new("Error fetching #{@seed_uri.to_s}")
    end

    if response.content_type.mime_type != 'text/html'
      raise InvalidContentTypeError.new("Invalid content-type: #{response.content_type}")
    end

  end
end

class FetchError < Exception
end

class InvalidContentTypeError < Exception
end

class RequestTimeoutError < Exception
end

class InvalidParam < Exception
end
