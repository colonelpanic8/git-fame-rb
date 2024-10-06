
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

    # Renders to stdout
    #
    # @return [void]
    def call
      table = TTY::Table.new(header: FIELDS)
      width = TTY::Screen.width

      lines_by_file.each do |email, files|
        author = authors.find { |a| a[:email] == email }
        lines = files.values.sum

        table << [author[:name], email, lines.f]

        # Display lines by file, sorted by most lines
        sorted_files = files.sort_by { |_, loc| -loc }
        sorted_files.each do |file, loc|
          table << ["", "File: #{file}", "#{loc}"]
        end
      end

      print table.render(:unicode, width: width, resize: true, alignment: [:center])
    end

    private

    def contributions
      result.contributions.sort_by(&:lines)
    end

    def dist_for_author(email)
      # Implement logic for calculating distribution for the author
      # Placeholder method
      "N/A"
    end
  end
end
