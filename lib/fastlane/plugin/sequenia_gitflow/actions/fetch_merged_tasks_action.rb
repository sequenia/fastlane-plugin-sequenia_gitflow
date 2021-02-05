require 'fastlane/action'
require_relative '../helper/sequenia_gitflow_helper'

module Fastlane
  module Actions
    class FetchMergedTasksAction < Action
      def self.run(params)
        last_tag = params[:last_release_tag]
        regexp = params[:feature_branches_regexp]
        with_prefix = params[:with_prefix]

        if !Helper::SequeniaGitflowHelper.tag_exist?(last_tag)
          UI.user_error!("Tag '#{last_tag}' doesn't exist")
        end

        all_branch_commits = Helper::SequeniaGitflowHelper.current_branch_all_commit_hashes(last_tag)
        merge_commits = Helper::SequeniaGitflowHelper.current_branch_merge_commit_hashes(last_tag)

        branches = Helper::SequeniaGitflowHelper.fetch_merged_task_branches(
          all_branch_commits,
          merge_commits,
          regexp
        )

        value = branches.map do |b|
          components = b.split('/').last.split('_')
          with_prefix ? "#{components[0]}_#{components[1]}" : components[0]
        end
                        .sort
        return value
      rescue => ex
        UI.error(ex)
        UI.error('Failed')
      end

      def self.description
        'Fetch merged into current branch feature tasks after last release tag'
      end

      def self.details
        ''
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :last_release_tag,
                                       description: 'Tag of the last release',
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :feature_branches_regexp,
                                       description: 'Regular expression that matching feature branches names',
                                       optional: true,
                                       default_value: /^(.)*\/(task)\/(\d)+_(.)*$/,
                                       type: Regexp),
          FastlaneCore::ConfigItem.new(key: :with_prefix,
                                       description: 'Does feature branches names have prefix from project\'s identifier (like IOS, WIL, WEST etc.)',
                                       optional: true,
                                       default_value: false,
                                       type: Boolean)
        ]
      end

      def self.return_value
        'Returns tasks identifiers'
      end

      def self.authors
        ['Semen Kologrivov']
      end

      def self.is_supported?(_)
        true
      end

      def self.example_code
        [
          'git_fetcher(last_release_tag: "build/1.0.0(35)")'
        ]
      end

      def self.return_type
        :string
      end
    end
  end
end
