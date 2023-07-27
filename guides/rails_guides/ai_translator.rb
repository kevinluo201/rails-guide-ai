# frozen_string_literal: true

require 'openai'
require 'digest'
require 'yaml'

module RailsGuides
  class AiTranslator
    OPENAI_ACCESS_TOKEN = ENV['OPENAI_ACCESS_TOKEN']
    OPENAI_MODEL = "gpt-3.5-turbo"
    OPENAI_TEMPERATURE = 0.2
    OPENAI_REQUEST_TIMEOUT = 360

    BUFFER_SIZE = 700
    LANGUAGES = {
      'zh-TW' => "Traditional Chinese used in Taiwan(台灣繁體中文).",
      'pt-BR' => 'Brazilian Portuguese',
      'fr' => 'French',
      'lt' => 'Lithuanian',
    }
    FILETYPE = {
      'md' => 'Markdown',
      'erb' => 'Embeded Ruby XML',
    }

    def initialize(file:, target_language:, skippable: true)
      @client = OpenAI::Client.new(
        access_token: OPENAI_ACCESS_TOKEN,
        request_timeout: OPENAI_REQUEST_TIMEOUT,
      )
      @file = file
      @file_ext = file.split('.').last
      @target_language = target_language
      @target_file = "#{target_language}/#{file}"
      @system_prompt = "Translate the technical document to #{LANGUAGES[target_language]} without adding any new content."
      @skippable = skippable
    end

    def translate
      if @file_ext == 'md'
        translate_markdown
      else
        translate_file
      end
    end

    def translate_file
      puts 'Start translate file: ' + @file + ' ...'
      start_t = Time.now

      buffer = []
      result = ''
      File.readlines(@file).each do |line|
        if line == "\n" && buffer.join.split.length > BUFFER_SIZE
          translated_text = ai_translate(buffer.join)
          result += translated_text + "\n"
          buffer = []
        else
          buffer << line
        end
      end

      if buffer.length > 0
        translated_text = ai_translate(buffer.join)
        result += translated_text
      end

      File.open(@target_file, 'w') { |f| f << result }

      end_t = Time.now
      puts "Translate file: #{@file} in #{end_t - start_t} seconds"
    end

    def translate_markdown
      if @skippable && no_update_needed?
        puts 'Skip translate file: ' + @file
        return
      end

      state = :readline
      buffer = []
      result = ''
      links = []
      puts 'Start translate markdown file: ' + @file + ' ...'

      File.readlines(@file).each do |line|
        if /DO NOT READ THIS FILE ON GITHUB,/ =~ line
          result += (line.chomp + ", original file md5: #{file_md5(@file)}\n")
        elsif /^\[\S+\]: \S+$/ =~ line
          links << line
        elsif /```/ =~ line
          buffer << line
          state = state == :codeblock ? :readline : :codeblock
        elsif line == "\n" && state == :readline && buffer.join.split.length > BUFFER_SIZE
          translated_text = ai_translate(buffer.join)
          result += translated_text + "\n"
          buffer = []
        else
          buffer << line
        end
      end

      if buffer.length > 0
        translated_text = ai_translate(buffer.join)
        result += translated_text
      end

      result += "\n"
      links.each do |link|
        result += link
      end

      File.open(@target_file, 'w') { |f| f << result }

      puts 'Finish translate markdown file: ' + @file
    end

    def ai_translate(text, system_prompt: nil)
      @system_prompt = system_prompt if system_prompt

      loop do
        response = @client.chat(
          parameters: {
            model: OPENAI_MODEL,
            messages: [
              { role: 'system', content: @system_prompt },
              { role: 'user', content: text },
            ],
            temperature: OPENAI_TEMPERATURE,
            })
        if response['error']
          # do nothing
        else
          puts "total tokens: #{response['usage']['total_tokens']}"
          return response['choices'][0]['message']['content']
        end
      end
    end

    def translate_document_yaml
      yaml = YAML.load_file(@file)
      new_yaml = []
      prompt = "Translate the exact input to #{LANGUAGES[@target_language]}"
      yaml.each_with_index do |block, index|
        block['name'] = ai_translate(block['name'], system_prompt: prompt)
        block['documents'].map! do |document|
          filename = "#{@target_language}/#{document['url'].delete_suffix('.html')}.md"
          title = /^(.+)\n={3,}/.match(File.read(filename))[1]
          {
            'name' => title,
            'url' => document['url'],
            'description' => ai_translate(document['description'], system_prompt: prompt)
          }
        end

        new_yaml << block
      end

      File.write(@target_file, YAML.dump(new_yaml))
    end

    private

    def file_md5(file)
      Digest::MD5.file(file).hexdigest
    end

    def no_update_needed?
      return false unless File.exist?(@target_file)

      original_file_md5 = File.open(@target_file, &:readline).chomp.split('original file md5: ').last
      original_file_md5 == file_md5(@file)

    rescue EOFError
      false
    end
  end
end