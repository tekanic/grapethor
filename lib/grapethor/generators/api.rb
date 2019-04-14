require 'thor/group'
require 'yaml'

module Grapethor
  class Api < Thor::Group
    include Thor::Actions
    include Grapethor::Utils

    attr_reader :api_version,
                :app_path

    namespace :api

    def self.exit_on_failure?
      true
    end

    def self.source_root
      File.join(__dir__, '..')
    end


    argument :version, type: :string,
                       desc: 'API version'

    class_option :path,  aliases: '-p',
                         type: :string,
                         default: '.',
                         desc: 'Relative path to application directory'


    def parse_args_and_opts
      @api_version = version.downcase
      @app_path    = options[:path]
    end


    def validate_target_app
      unless app_dir_exists?
        alert <<~MSG
                Directory '#{app_path}' does not seem to be generated by Grapethor or root application directory.\n
                Please 'cd' into application root diretory or use '--path' option.
              MSG
        exit
      end
    end


    def create_api
      report("Creating new API...") do
        directory 'templates/api', app_path
        directory "templates/api_#{app_test_framework}", app_path
        insert_into_file "#{app_path}/api/base.rb",
                         "\s\s\s\smount API#{api_version}::Base\n",
                         :before => "\s\s\s\s# mount API<VERSION>::Base\n"
      end
    end


    private

    def app_dir_exists?
      File.exist?("#{app_path}/api/base.rb")
    end

    def app_name
      @app_name ||= YAML.load(File.read(CONFIG_FILENAME))['app_name']
    end

    def app_prefix
      @app_prefix ||= YAML.load(File.read(CONFIG_FILENAME))['app_prefix']
    end

    def app_swagger?
      @app_swagger||= YAML.load(File.read(CONFIG_FILENAME))['app_swagger']
    end
  end
end
