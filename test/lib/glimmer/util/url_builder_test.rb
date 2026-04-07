require './test/test_helper'

require 'glimmer/util/url_builder'

describe Glimmer::Util::UrlBuilder do
  subject do
    Glimmer::Util::UrlBuilder.new
  end
  
  it 'builds URL with specified host' do
    url = subject.host('www.google.com').to_url
    _(url).must_equal 'https://www.google.com'
  end
  
  it 'builds URL with nil host' do
    url = subject.host(nil).to_url
    _(url).must_equal 'https://'
  end
  
  it 'builds URL with unspecified host' do
    url = subject.to_url
    _(url).must_equal 'https://'
  end
  
  it 'builds URL with specified scheme and host' do
    url = subject.scheme('http').host('www.google.com').to_url
    _(url).must_equal 'http://www.google.com'
  end
  
  it 'builds URL with specified scheme, host, and path' do
    url = subject.scheme('http').host('www.google.com').path('/results').to_url
    _(url).must_equal 'http://www.google.com/results'
  end
  
  it 'builds URL with specified scheme, host, and path without forward slash at the beginning' do
    url = subject.scheme('http').host('www.google.com').path('results').to_url
    _(url).must_equal 'http://www.google.com/results'
  end
  
  it 'builds URL with specified scheme, host, path, and param' do
    url = subject.scheme('http').host('www.google.com').path('/results').param('q', 'sports').to_url
    _(url).must_equal 'http://www.google.com/results?q=sports'
  end
  
  it 'builds URL with specified scheme, host, path, and 2 params' do
    url = subject.scheme('http').host('www.google.com').path('/results').param('q', 'sports').param('year', '2039').to_url
    _(url).must_equal 'http://www.google.com/results?q=sports&year=2039'
  end
  
  it 'builds URL with specified scheme, host, path, and query' do
    url = subject.scheme('http').host('www.google.com').path('/results').query('q=sports&year=2039').to_url
    _(url).must_equal 'http://www.google.com/results?q=sports&year=2039'
  end
  
  it 'builds URL with specified scheme, host, path, query, and extra param' do
    url = subject.scheme('http').host('www.google.com').path('/results').query('q=sports&year=2039').param('month', 'apr').to_url
    _(url).must_equal 'http://www.google.com/results?q=sports&year=2039&month=apr'
  end
  
  it 'builds URL with specified scheme, host, path, query, and extra param that overrides an existing param from query' do
    url = subject.scheme('http').host('www.google.com').path('/results').query('q=sports&year=2039').param('q', 'news').to_url
    _(url).must_equal 'http://www.google.com/results?q=news&year=2039'
  end
  
  it 'builds URL with specified scheme, host, path, param, and fragment' do
    url = subject.scheme('http').host('www.google.com').path('/results').param('q', 'sports').fragment('#yesterday').to_url
    _(url).must_equal 'http://www.google.com/results?q=sports#yesterday'
  end
  
  it 'builds URL with specified scheme, host, port, path, param, and fragment' do
    url = subject.scheme('http').host('localhost').port('3000').path('/results').param('q', 'sports').fragment('#yesterday').to_url
    _(url).must_equal 'http://localhost:3000/results?q=sports#yesterday'
  end
  
  it 'builds URL with specified scheme, host, path, param, and fragment without # at the beginning' do
    url = subject.scheme('http').host('www.google.com').path('/results').param('q', 'sports').fragment('yesterday').to_url
    _(url).must_equal 'http://www.google.com/results?q=sports#yesterday'
  end
  
  it 'builds URL with specified URL with everything but port' do
    url = subject.url('http://www.google.com/results?q=sports#yesterday').to_url
    _(url).must_equal 'http://www.google.com/results?q=sports#yesterday'
  end
  
  it 'builds URL with specified URL with port' do
    url = subject.url('http://localhost:3000/results?q=sports#yesterday').to_url
    _(url).must_equal 'http://localhost:3000/results?q=sports#yesterday'
  end
  
  it 'builds URL with specified URL not containing query params' do
    url = subject.url('http://www.google.com/results#yesterday').to_url
    _(url).must_equal 'http://www.google.com/results#yesterday'
  end
  
  it 'builds URL with specified URL not containing query params or fragment' do
    url = subject.url('http://www.google.com/results').to_url
    _(url).must_equal 'http://www.google.com/results'
  end
  
  it 'builds URL with specified URL not containing path, query params or fragment' do
    url = subject.url('http://www.google.com').to_url
    _(url).must_equal 'http://www.google.com'
  end
  
  it 'builds URL with specified URL not containing scheme, path, query params or fragment' do
    url = subject.url('www.google.com').to_url
    _(url).must_equal 'https://www.google.com'
  end
  
  it 'builds URL with specified URL not containing host, path, query params or fragment' do
    url = subject.url('http://').to_url
    _(url).must_equal 'http://'
  end
  
  it 'builds URL with specified URL not containing scheme, host, path, query params or fragment' do
    url = subject.url('').to_url
    _(url).must_equal 'https://'
  end
  
  it 'builds URL with specified URL and an extra query parameter' do
    url = subject.url('http://www.google.com/results?q=sports#yesterday').param('year', '2040').to_url
    _(url).must_equal 'http://www.google.com/results?q=sports&year=2040#yesterday'
  end
end
