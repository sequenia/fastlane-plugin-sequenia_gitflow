require 'fastlane/action'
require_relative '../helper/sequenia_gitflow_helper'

module Fastlane
  module Actions
    class FetchMergedTasksAction < Action
      def self.run(params)
        last_tag = params[:last_release_tag]
        first_commit = Helper::SequeniaGitflowHelper.first_commit
        regexp = params[:feature_branches_regexp]
        already_with_prefix = params[:already_with_prefix]

        if !last_tag.nil? && !Helper::SequeniaGitflowHelper.tag_exist?(last_tag)
          UI.user_error!("Tag '#{last_tag}' doesn't exist")
        end

        all_branch_commits = Helper::SequeniaGitflowHelper.current_branch_all_commit_hashes(last_tag || first_commit)
        merge_commits = Helper::SequeniaGitflowHelper.current_branch_merge_commit_hashes(last_tag || first_commit)

        branches = Helper::SequeniaGitflowHelper.fetch_merged_task_branches(
          all_branch_commits,
          merge_commits,
          regexp
        )
        value = branches.map do |b|
          components = b.split('/').last.split('_')
          already_with_prefix ? "#{components[0]}_#{components[1]}" : components[0]
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
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :feature_branches_regexp,
                                       description: 'Regular expression that matching feature branches names',
                                       optional: true,
                                       default_value: /^(.)*\/(task)\/(\d)+_(.)*$/,
                                       type: Regexp),
          FastlaneCore::ConfigItem.new(key: :already_with_prefix,
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
          'fetch_merged_tasks(last_release_tag: "build/1.0.0(35)")'
        ]
      end

      def self.return_type
        :string
      end
    end
  end
end
