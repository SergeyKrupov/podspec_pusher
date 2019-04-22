require 'thor'
require 'cocoapods'
require 'git'

module PodspecPusher

  class PusherCLI < Thor
    desc 'podspec_pusher [repo] [podspec]', 'Push podspec'
    def push(podspecs_repo, podspec_file)
      raise "No repo specified" unless podspecs_repo
      raise "No podspec specified" unless podspec_file

      podspec = Pod::Specification.from_file podspec_file
      repo = Git.open Dir.pwd
      repo.pull

      new_tag_name = podspec.version.to_s

      if repo.tags.find { |tag| tag.name == new_tag_name }
        raise "Tag #{new_tag_name} already exists"
      end

      repo.add_tag new_tag_name
      repo.push'origin', new_tag_name
      argv = CLAide::ARGV.new([podspecs_repo, podspec_file, '--allow-warnings', '--skip-tests', '--no-overwrite'])
      command = Pod::Command::Repo::Push.new(argv)
      command.run
    end
  end
end
