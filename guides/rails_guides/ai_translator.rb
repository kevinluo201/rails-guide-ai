# frozen_string_literal: true

require 'openai'
require 'digest'
require 'yaml'

class ExceedTokensLimitError < StandardError; end

module RailsGuides
  class AiTranslator
    OPENAI_ACCESS_TOKEN = ENV['OPENAI_ACCESS_TOKEN']
    OPENAI_MODEL = "gpt-3.5-turbo"
    OPENAI_TEMPERATURE = 0.2
    OPENAI_REQUEST_TIMEOUT = 360
    OPENAI_MAX_TOKENS = 4096

    LANGUAGES = {
      'zh-TW' => "Traditional Chinese used in Taiwan(台灣繁體中文).",
      'jp' => 'Japanese',
      'ko' => 'Korean',
      'es' => 'Spanish',
      'pt-BR' => 'Brazilian Portuguese',
      'fr' => 'French',
      'th' => 'Thai',
      'lt' => 'Lithuanian',
      'zh-CN' => 'Simplified Chinese',
    }
    FILETYPE = {
      'md' => 'Markdown',
      'erb' => 'Embeded Ruby XML',
    }

    def initialize(target_language:, buffer_size: 700)
      @client = OpenAI::Client.new(
        access_token: OPENAI_ACCESS_TOKEN,
        request_timeout: OPENAI_REQUEST_TIMEOUT,
      )
      @target_language = target_language
      @buffer_size = buffer_size
    end

    def translate_files(files)
      current_buffer_size = @buffer_size

      while files.length > 0 && current_buffer_size > 0
        files.dup.each do |file|
          if translate_file(file, buffer_size: current_buffer_size)
            files.delete(file)
          end
        end

        if files.length > 0
          current_buffer_size -= 100
          raise 'Buffer size too small' if current_buffer_size <= 0
          puts "Current buffer size: #{current_buffer_size}"
        end
      end
    end

    def translate_file(file, buffer_size: @buffer_size, force_update: false)
      if file.end_with?('.md')
        loop do
          begin
            translate_markdown(file, buffer_size: buffer_size, force_update: force_update)
            break
          rescue ExceedTokensLimitError
            if buffer_size <= 0
              raise 'Buffer size too small' if buffer_size <= 0
            else
              buffer_size -= 100
              puts "decrease buffer size: #{buffer_size}"
            end
          end
        end
      else
        translate_plain_file(file)
      end

      true
    end

    def translate_plain_file(file)
      puts 'Start translate file: ' + file + ' ...'
      start_t = Time.now

      buffer = []
      result = ''
      File.readlines(file).each do |line|
        if line == "\n" && buffer.join.split.length > @buffer_size
          translated_text = ai_translate(buffer.join)[:text]
          result += translated_text + "\n"
          buffer = []
        else
          buffer << line
        end
      end

      if buffer.length > 0
        translated_text = ai_translate(buffer.join)[:text]
        result += translated_text
      end

      File.open(target_file(file), 'w') { |f| f << result }

      end_t = Time.now
      puts "Translate file: #{file} in #{end_t - start_t} seconds"
    end

    def translate_markdown(file, buffer_size: @buffer_size, force_update: false)
      if !force_update && no_update_needed?(file)
        puts 'Skip translate file: ' + file
        return
      end

      state = :readline
      buffer = []
      result = ''
      links = []
      puts 'Start translate markdown file: ' + file + ' ...'

      File.readlines(file).each do |line|
        if line.include?('DO NOT READ THIS FILE ON GITHUB')
          result += (line.chomp + ", original file md5: #{file_md5(file)}\n")
        elsif /^\[\S+\]: \S+$/.match?(line)
          links << line
        elsif line.include?('```')
          buffer << line
          state = state == :codeblock ? :readline : :codeblock
        elsif line == "\n" && state == :readline && buffer.join.split.length > buffer_size
          response = ai_translate(buffer.join)

          raise ExceedTokensLimitError if response[:tokens] >= OPENAI_MAX_TOKENS

          translated_text = response[:text]
          result += translated_text + "\n"
          buffer = []
        else
          buffer << line
        end
      end

      if buffer.length > 0
        translated_text = ai_translate(buffer.join)[:text]
        result += translated_text
      end

      result += "\n"
      links.each do |link|
        result += link
      end

      File.open(target_file(file), 'w') { |f| f << result }

      puts 'Finish translate markdown file: ' + file
    end

    def ai_translate(text, system_prompt: nil)
      system_prompt ||= "Translate the technical document to #{LANGUAGES[@target_language]} without adding any new content."

      loop do
        response = @client.chat(
          parameters: {
            model: OPENAI_MODEL,
            messages: [
              { role: 'system', content: system_prompt },
              { role: 'user', content: text },
            ],
            temperature: OPENAI_TEMPERATURE,
            })
        if response['error']
          # do nothing
        else
          puts "total tokens: #{response['usage']['total_tokens']}"
          return {
            text: response['choices'][0]['message']['content'],
            tokens: response['usage']['total_tokens'],
          }
        end
      end
    end

    def generate_document_yaml
      file = 'documents.yaml'
      yaml = YAML.load_file(file)
      new_yaml = []
      prompt = "Translate the exact input to #{LANGUAGES[@target_language]}"
      yaml.each_with_index do |block, index|
        block['name'] = ai_translate(block['name'], system_prompt: prompt)[:text]
        block['documents'].map! do |document|
          filename = "#{@target_language}/#{document['url'].delete_suffix('.html')}.md"
          title = /^(.+)\n={3,}/.match(File.read(filename))[1]
          {
            'name' => title,
            'url' => document['url'],
            'description' => ai_translate(document['description'], system_prompt: prompt)[:text]
          }
        end

        new_yaml << block
      end

      File.write(target_file(file), YAML.dump(new_yaml))
    end

    private

    def file_md5(file)
      Digest::MD5.file(file).hexdigest
    end

    def target_file(file)
      "#{@target_language}/#{file}"
    end

    def no_update_needed?(file)
      t_file = target_file(file)
      return false unless File.exist?(t_file)

      original_file_md5 = File.open(t_file, &:readline).chomp.split('original file md5: ').last
      original_file_md5 == file_md5(file)

    rescue EOFError
      false
    end
  end
end