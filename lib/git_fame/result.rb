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

    # @return [Hash<String, Object>]
    # Returns a hash representing the full directory tree structure.
    # Each level contains "counts" (mapping authors to counts) and "children" (further nested paths).
    def lines_by_file
      contributions.each_with_object({ "counts" => {}, "children" => {} }) do |contribution, result|
        author_email = contribution.author[:email]
        # Increment the root-level count for the author
        current_level = result["children"]
        result["counts"][author_email] = (result["counts"][author_email] || 0) + contribution.lines
        contribution.lines_by_file.each do |file, loc|
          # Reset current_level to the root for each file
          current_level = result["children"]
          path_parts = file.split(File::SEPARATOR)
          # Traverse each directory/file level
          path_parts.each_with_index do |part, index|
            # Ensure there's an entry for the directory/file level
            current_level[part] ||= { "counts" => {}, "children" => {} }
            # Increment the count for this author at the current level
            current_level[part]["counts"][author_email] = (current_level[part]["counts"][author_email] || 0) + loc
            # Move deeper into the hierarchy for the children if this is not the last part
            current_level = current_level[part]["children"] unless index == path_parts.size - 1
          end
        end
      end
    end
  end
end
