# frozen_string_literal: true

$:.unshift __dir__

require 'fileutils'
require 'rails_guides/ai_translator.rb'

target = ARGV[0]
Dir.chdir("source")

if !File.exist?("#{target}/epub")
  FileUtils.mkdir_p("#{target}/epub")
end

translator = RailsGuides::AiTranslator.new(target_language: target)
file = ARGV[1]
if file
  translator.translate_file(file, force_update: true)
else
  files = Dir['*'].reject { |f| File.directory?(f) } + Dir['epub/*']
  files.delete('documents.yaml')
  files.sort! do |a, b|
    if a.end_with?('.md') && !b.end_with?('.md')
      -1
    elsif !a.end_with?('.md') && b.end_with?('.md')
      1
    else
      a <=> b
    end
  end
  translator.translate_files(files)
  translator.generate_document_yaml
end
