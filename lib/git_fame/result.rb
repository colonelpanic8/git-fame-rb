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

    # @return [Hash<String, Hash<String, Object>>]
    # Returns a hash where each key is an author's email, and each value is a nested hash representing the directory tree
    # structure, with line counts stored in a "count" key and subdirectories/files stored in "children".
    def lines_by_file
      contributions.each_with_object(Hash.new { |h, k| h[k] = {} }) do |contribution, result|
        author_email = contribution.author[:email]

        contribution.lines_by_file.each do |file, loc|
          path_parts = file.split(File::SEPARATOR)

          # Start at the root of the author's tree
          current_level = result[author_email]

          # Traverse each directory/file level
          path_parts.each_with_index do |part, index|
            if index == path_parts.size - 1
              # This is the file, store its own count
              current_level[part] ||= { "count" => 0, "children" => {} }
              current_level[part]["count"] += loc
            else
              # For directories, ensure we have a "children" key and move deeper into the hierarchy
              current_level[part] ||= { "count" => 0, "children" => {} }
              current_level[part]["count"] += loc  # Increment the directory count
              current_level = current_level[part]["children"]
            end
          end
        end
      end
    end
  end
end
