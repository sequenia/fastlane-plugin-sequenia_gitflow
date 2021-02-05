describe Fastlane::Actions::SequeniaGitflowAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The sequenia_gitflow plugin is working!")

      Fastlane::Actions::SequeniaGitflowAction.run(nil)
    end
  end
end
