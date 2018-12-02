require 'logger'
require 'optparse'
require_relative './crawler'

def parse_cli_opts
  options = {}

  OptionParser.new do |opt|
    opt.on('--seed_url URL to be crawled') { |o| options[:seed_url] = o }
    opt.on('--timeout Request timeout in seconds') { |o| options[:timeout] = o.to_i }
    opt.on('--max_redirects Max redirect count if response status is 3xx') { |o| options[:max_redirects] = o.to_i }
  end.parse!

  options
end

if __FILE__ == $0
  logger = Logger.new(STDOUT)

  cli_opts = parse_cli_opts
  logger.info("Running with these options: #{cli_opts}")

  begin
    seed_url = cli_opts.delete(:seed_url)
    Crawler.new(seed_url, **cli_opts).fetch_links(output_to: STDOUT)
  rescue Exception => e
    logger.error(e.to_s)
  end
end
