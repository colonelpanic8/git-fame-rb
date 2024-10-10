require "json"
require "tty-screen"
require "tty-table"
require "tty-box"
require "erb"

module GitFame
  class Render < Base
    FIELDS = [:name, :email, :lines].map(&:to_s).freeze

    attribute :branch, Types::String
    attribute :result, Result
    delegate_missing_to :result

    using Extension

    # Outputs lines_by_file as JSON
    #
    # @return [void]
    def call
      # Convert the lines_by_file data to JSON
      output = lines_by_file.to_json

      # Print the JSON output
      puts output
    end

    private

    def contributions
      result.contributions.sort_by(&:lines)
    end

    def dist_for_author(email)
      # Placeholder method
      "N/A"
    end
  end
end
