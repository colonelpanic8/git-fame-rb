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
    # Returns a hash where each key is an author's email, and each value is another hash mapping file paths (including subdirectories) to line counts.
    def lines_by_file
      contributions.each_with_object(Hash.new { |h, k| h[k] = Hash.new(0) }) do |contribution, result|
        author_email = contribution.author[:email]
        contribution.lines_by_file.each do |file, loc|
          # Split the file path into its directories
          path_parts = file.split(File::SEPARATOR)

          # Iterate over each part to build paths for subdirectories
          (1..path_parts.size).each do |i|
            sub_path = path_parts.first(i).join(File::SEPARATOR)
            result[author_email][sub_path] += loc
          end
        end
      end
    end
  end
end
