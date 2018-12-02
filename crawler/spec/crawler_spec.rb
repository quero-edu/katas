require 'http'
require 'stringio'
require_relative '../crawler'

describe Crawler do
  let(:crawler) {
    ->(
      fixture_name = nil,
      seed_url: 'http://fake.com/',
      status: 200,
      content_type: 'text/html',
      timeout: 2,
      max_redirects: 7
    ) {
      crawler = Crawler.new(seed_url, timeout: timeout, max_redirects: max_redirects)

      resp = HTTP::Response.new({
        version: 1.1,
        status: status,
        body: fixture_name.nil? ? '' : fixture(fixture_name),
        headers: {content_type: content_type}
      })

      allow(HTTP).to receive(:follow).and_return(HTTP)
      allow(HTTP).to receive(:timeout).and_return(HTTP)
      allow(HTTP).to receive(:get).and_return(resp)

      crawler
    }
  }

  describe 'Response parsing' do
    it 'returns links from page' do
      expect(crawler['two-internal-links'].fetch_links).to eq(['http://fake.com/1', 'http://fake.com/2'])
    end

    it 'ignores external links' do
      expect(crawler['one-internal-one-external'].fetch_links).to eq(['http://fake.com/3'])
    end

    it 'accepts internal links starting with slash' do
      expect(crawler['relative-link'].fetch_links).to eq(['http://fake.com/4', 'http://fake.com/wow'])
    end

    it 'ignores empty hrefs' do
      expect(crawler['empty-href'].fetch_links).to eq([])
    end
  end

  describe 'Actual request' do
    it 'makes request with correct params' do
      crawler[max_redirects: 9, timeout: 8, seed_url: 'http://yay.wow'].fetch_links
  
      expect(HTTP).to have_received(:follow).with(max_hops: 9)
      expect(HTTP).to have_received(:timeout).with(8)
      expect(HTTP).to have_received(:get).with('http://yay.wow')
    end
  end

  describe 'Output' do
    it 'outputs found links' do
      io = StringIO.new
      crawler['two-internal-links'].fetch_links(output_to: io)
  
      expect(io.string).to eq("http://fake.com/1\nhttp://fake.com/2\n")
    end
  end

  describe 'Errors' do
    it 'raises error when request times out' do
      url, timeout = 'http://fake.com', 19
      crawler = Crawler.new(url, timeout: timeout)
      allow(crawler).to receive(:fetch_html).and_raise(HTTP::TimeoutError)
  
      expect { crawler.fetch_links }.to raise_error(RequestTimeoutError, /Timed out after 19 seconds/)
    end
  
    it 'raises exception when response status is 404' do
      expect {crawler['empty-href', status: 404].fetch_links }.to raise_error(FetchError, "Error fetching http://fake.com/")
    end
  
    it 'raises error when response is not HTML' do
      expect {
        crawler[content_type: 'application/json'].fetch_links
      }.to raise_error(InvalidContentTypeError)
    end
  
    it 'raises error when URL is invalid' do
      expect { crawler[seed_url: 'wow.yay'].fetch_links }.to raise_error(InvalidParam, 'Invalid URL: wow.yay')
    end
  
    it 'raises error when timeout is invalid' do
      expect { crawler[timeout: 'spam'].fetch_links }.to raise_error(InvalidParam, 'Invalid timeout: spam')
    end
  
    it 'raises error when timeout is invalid' do
      expect { crawler[max_redirects: 'wow'].fetch_links }.to raise_error(InvalidParam, 'Invalid max redirects: wow')
    end
  end
end

def fixture(name)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', "#{name}.html"))
end