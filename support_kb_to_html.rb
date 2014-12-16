#! /usr/bin/env ruby

require 'redcarpet'
require 'yaml'
require 'fileutils'
require 'stringio'

error_codes = YAML.load_file(File.expand_path('../v2.yml', __FILE__))
support_kb = YAML.load_file(File.expand_path('../v2_support_kb.yml', __FILE__))

codes_not_documented = error_codes.keys - support_kb.keys
if codes_not_documented.any?
  # Can be changed to `fail` when all KB articles have been written
  warn "Not all errors are in the Support Knowledge Base: #{codes_not_documented.join(', ')}"
end

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
docs_dir = File.expand_path('../docs', __FILE__)
FileUtils.rm_rf(docs_dir)
FileUtils.mkdir_p(docs_dir)

index = StringIO.new
index << "# Index\n"

support_kb.each do |error_code, kb_article|
  index << "* [#{error_code}: #{error_codes[error_code]['name']}](#{error_code}.html)\n"

  File.open "#{docs_dir}/#{error_code}.html", 'w+' do |file|
    file.write(markdown.render(kb_article))
  end
end

File.open("#{docs_dir}/index.html", 'w+') do |file|
  file.write(markdown.render(index.string))
end
