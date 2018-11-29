require 'http'
require_relative '../crawler'

describe 'Links' do
  it 'returns a list of all links in a page' do
    url = 'https://news.ycombinator.com'
    crawler = Crawler.new
    crawler.stub(:get_url).with(url).and_return('<a href="http://google.com"></a>')
    links = ['http://google.com']

    crawler_links = crawler.get_links(url)
    expect(crawler_links.class).to eq(Array)
    expect(crawler_links).to eq(links)
  end  
end

describe 'inside links' do
  it 'returns two links' do
    url = 'https://news.ycombinator.com'
    crawler = Crawler.new
    crawler.stub(:get_url).with(url).and_return('<div><a href="http://google.com"></a><a href="http://facebook.com"></a></div>')
    links = ['http://google.com', 'http://facebook.com']
    
    crawler_links = crawler.get_links(url)
    expect(crawler_links.class).to eq(Array)
    expect(crawler_links).to eq(links)
  end
end

describe 'inside links' do
  it 'returns two links' do
    url = 'https://news.ycombinator.com'
    crawler = Crawler.new
    crawler.stub(:get_url).with(url).and_return('<div><a href="http://google.com"></a><a href="http://facebook.com"></a></div>')
    links = ['http://google.com', 'http://facebook.com']
    
    crawler_links = crawler.get_links(url)
    expect(crawler_links.class).to eq(Array)
    expect(crawler_links).to eq(links)
  end
end
