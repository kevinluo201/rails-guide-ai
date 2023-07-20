# frozen_string_literal: true

$:.unshift __dir__

require 'fileutils'
require 'rails_guides/ai_translator.rb'
require 'rails_guides/post_translate_tasks.rb'

target = ARGV[0] || 'zh-TW'
Dir.chdir("source")

if !File.exist?("#{target}/epub")
  FileUtils.mkdir_p("#{target}/epub")
end

file = ARGV[1]
if file
  start_t = Time.now
  RailsGuides::AiTranslator.new(file: file, target_language: target, skippable: false).translate
  end_t = Time.now
  puts "Translate file: #{file} in #{end_t - start_t} seconds"
else
  files = Dir['*'].reject { |f| File.directory?(f) } + Dir['epub/*']
  files.sort! { |a, b| a.end_with?('.md') ? (a <=> b) : 1 }
  files.each do |file|
    start_t = Time.now

    RailsGuides::AiTranslator.new(file: file, target_language: target).translate

    end_t = Time.now
    puts "Translate file: #{file} in #{end_t - start_t} seconds"
  end
end
