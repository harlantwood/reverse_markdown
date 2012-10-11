require 'spec_helper'

describe ReverseMarkdown::Mapper do

  let(:input)    { File.read('spec/assets/basic.html') }
  let(:document) { Nokogiri::HTML(input) }
  subject { ReverseMarkdown.parse_string(input) }

  it { should match /# h1\n/ }
  it { should match /## h2\n/ }
  it { should match /### h3\n/ }
  it { should match /#### h4\n/ }
  it { should match /\*em\*/ }
  it { should match /\*\*strong\*\*/ }
  it { should match /`code`/ }
  it { should match /---/ }

end