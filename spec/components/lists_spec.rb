require 'spec_helper'

describe ReverseMarkdown::Mapper do

  let(:input)    { File.read('spec/assets/lists.html') }
  let(:document) { Nokogiri::HTML(input) }
  subject { ReverseMarkdown.parse_string(input) }

  it { should match /- unordered list entry\n/ }
  it { should match /1. ordered list entry\n/ }
  it { should match /1. list entry 1st hierarchy\n/ }
  it { should match /\s{2}- nested unsorted list entry/ }
  it { should match /\s{4}1. deep nested list entry/ }

end