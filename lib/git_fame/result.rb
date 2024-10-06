# frozen_string_literal: true

module GitFame
  class Result < Base
    attribute :contributions, Types.Array(Contribution)

    # @return [Array<Author>]
    def authors
      contributions.map(&:author)
    end

    # @return [Array<String>]
    def commits
      contributions.flat_map do |c|
        c.commits.to_a
      end
    end

    # @return [Array<String>]
    def files
      contributions.flat_map do |c|
        c.files.to_a
      end
    end

    # @return [Integer]
    def lines
      contributions.sum(&:lines)
    end
    # @return [Hash<String, Hash<String, Integer>>]
    # Returns a hash where each key is an author's email, and each value is another hash mapping file paths to line counts.
    def lines_by_file
      contributions.each_with_object(Hash.new { |h, k| h[k] = Hash.new(0) }) do |contribution, result|
        author_email = contribution.author[:email]
        contribution.lines_by_file.each do |file, loc|
          result[author_email][file] += loc
        end
      end
    end
  end
end
