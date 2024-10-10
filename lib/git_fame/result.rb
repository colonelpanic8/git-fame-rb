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
    # Returns a hash where each level of the directory tree has counts associated with author emails.
    # Each level will have a hash of author emails, each containing "count" and "children" for the directory structure.
    def lines_by_file
      contributions.each_with_object({}) do |contribution, result|
        author_email = contribution.author[:email]

        contribution.lines_by_file.each do |file, loc|
          path_parts = file.split(File::SEPARATOR)

          # Start at the root of the tree
          current_level = result

          # Traverse each directory/file level
          path_parts.each_with_index do |part, index|
            # Ensure there's a hash for this directory/file level keyed by author email
            current_level[part] ||= {}
            current_level[part][author_email] ||= { "count" => 0, "children" => {} }

            # Update the count for this author at this level
            current_level[part][author_email]["count"] += loc

            # Move deeper into the hierarchy for the children
            current_level = current_level[part][author_email]["children"] unless index == path_parts.size - 1
          end
        end
      end
    end
  end
end
