require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class SequeniaGitflowHelper
      # Проверка, существует ли тэг в репозитории
      def self.tag_exist?(tag)
        !array_from_gitlog("git tag -l \"#{tag}\"").empty?
      end

      # Получение merge-коммитов от последнего релизного тэга до HEAD ветки
      def self.current_branch_merge_commit_hashes(tag)
        array_from_gitlog("git log \"#{tag}\"...HEAD --pretty=\"%H\" --merges")
      end

      # Получение всех коммитов текущей ветки
      def self.current_branch_all_commit_hashes(tag)
        array_from_gitlog("git log \"#{tag}\"...HEAD --pretty=\"%H\" --first-parent")
      end

      # Перевод хэшей коммитов в список веток
      def self.fetch_merged_task_branches(all_hashes, merge_hashes, regexp)
        merge_hashes.map { |hash| array_from_gitlog("git branch --remotes --contains #{hash} --merged") }
                    .flatten
                    .uniq
                    .select { |b| b =~ regexp }
                    .reject do |branch|
                      # Проверка, если в ветке всего один коммит и он находится в версионной ветке
                      last_commit = array_from_gitlog("git log --pretty=\"%H\" -p -1 #{branch}").first
                      all_hashes.include?(last_commit)
                    end
      end

      def self.array_from_gitlog(source)
        `#{source}`.split($/)
                   .map { |line| line.strip }
                   .filter { |line| !line.empty? }
      end
    end
  end
end
