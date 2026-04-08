require './test/test_helper'

require 'glimmer/util/url_query_string_builder'

describe Glimmer::Util::UrlQueryStringBuilder do
  subject do
    Glimmer::Util::UrlQueryStringBuilder.new
  end
  
  it 'builds query string from one param' do
    url = subject.param('q', 'sports').to_query_string
    _(url).must_equal 'q=sports'
  end
  
  it 'builds query string from 2 params provided one at a time' do
    url = subject.param('q', 'sports').param('year', '2040').to_s
    _(url).must_equal 'q=sports&year=2040'
  end
  
  it 'builds query string from 2 params provided one at a time, starting with ?' do
    url = subject.with_question_mark.param('q', 'sports').param('year', '2040').to_s
    _(url).must_equal '?q=sports&year=2040'
  end
  
  it 'builds query string from 2 params provided one at a time, starting with ? prefix (alias)' do
    url = subject.with_prefix.param('q', 'sports').param('year', '2040').to_s
    _(url).must_equal '?q=sports&year=2040'
  end
  
  it 'builds query string from params hash with string keys' do
    url = subject.params('q' => 'sports', 'year' => '2040').to_s
    _(url).must_equal 'q=sports&year=2040'
  end
  
  it 'builds query string from params hash with symbol keys' do
    url = subject.params(q: 'sports', year: '2040').to_s
    _(url).must_equal 'q=sports&year=2040'
  end
  
  it 'builds query string from an existing query string and one new param' do
    url = subject.query('q=sports&year=2040').param('month', 'apr').to_query_string
    _(url).must_equal 'q=sports&year=2040&month=apr'
  end
  
  it 'builds query string from an existing query string and one overriding param' do
    url = subject.query('q=sports&year=2040').param('year', '2038').to_query_string
    _(url).must_equal 'q=sports&year=2038'
  end
  
  it 'builds query string from an existing query string starting with ? and one new param' do
    url = subject.query('?q=sports&year=2040').param('month', 'apr').to_query_string
    _(url).must_equal 'q=sports&year=2040&month=apr'
  end
end
