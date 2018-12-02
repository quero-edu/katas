# Crawler

## Run

Usage:

```
Usage: main [options]
        --seed_url URL to be crawled
        --timeout Request timeout in seconds
        --max_redirects Max redirect count if response status is 3xx
```

**Example**

```
ruby main.rb --seed_url "http://www.globo.com" --timeout 5 --max_redirects 4
```

Errors are logged to stdout.
