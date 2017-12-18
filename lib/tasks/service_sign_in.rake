require 'yaml'

namespace :service_sign_in do
  desc "publish service_sign_in format"
  task :publish, [:yaml_file] => :environment do |_, args|
    USAGE_MESSAGE = "> usage: rake service_sign_in:publish[example.yaml]\n".freeze +
      "> service_sign_in YAML files live here: lib/service_sign_in"
    VALID_FILE_MESSAGE = "> You have not provided a valid file\n".freeze

    abort USAGE_MESSAGE unless args[:yaml_file]

    validator = ServiceSignInYamlValidator.new("lib/service_sign_in/#{args[:yaml_file]}")

    begin
      file = validator.validate

      if file.is_a?(Hash)
        content = Formats::ServiceSignInPresenter.new(file)
      else
        puts "Validation errors occurred:"
        puts file
        abort
      end
    rescue SystemCallError
      abort VALID_FILE_MESSAGE + USAGE_MESSAGE
    end

    ServiceSignInPublishService.call(content)
    puts "> #{args[:yaml_file]} has been published"
  end

  desc "Validate a service_sign_in YAML file"
  task :validate, [:yaml_file] => :environment do |_, args|
    USAGE_MESSAGE = "> usage: rake service_sign_in:validate[example.yaml]\n".freeze +
      "> service_sign_in YAML files live here: lib/service_sign_in"

    abort USAGE_MESSAGE unless args[:yaml_file]

    validator = ServiceSignInYamlValidator.new("lib/service_sign_in/#{args[:yaml_file]}")
    file = validator.validate

    if file.is_a?(Hash)
      puts "This is a valid YAML file"
    else
      puts "Validation errors occurred:"
      puts file
    end
  end

  desc "Validate all files in service_sign_in directiory are valid YAML files"
  task validate_all: [:environment] do
    directiory = File.join(Rails.root, "lib/service_sign_in")
    Dir.foreach(directiory) do |filename|
      next if filename == '.' or filename == '..'

      # Check file has right extension
      extension = File.extname(directiory + filename)
      if extension != '.yaml'
        abort "Warning: #{filename} does not have a .yaml file extension"
      end

      # Check file is valid YAML
      Rake::Task['service_sign_in:validate'].invoke(filename)
    end
  end
end
