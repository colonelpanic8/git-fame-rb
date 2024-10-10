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
      contributions.each_with_object({ "counts" => Hash.new(0), "children" => {} }) do |contribution, result|
        author_email = contribution.author[:email]

        # Increment the root-level count for the author
        result["counts"][author_email] += contribution.lines

        current_level = result["children"]

        contribution.lines_by_file.each do |file, loc|
          path_parts = file.split(File::SEPARATOR)

          # Traverse each directory/file level
          path_parts.each_with_index do |part, index|
            # Ensure there's an entry for the directory/file level
            current_level[part] ||= { "counts" => Hash.new(0), "children" => {} }

            # Increment the count for this author at the current level
            current_level[part]["counts"][author_email] += loc

            # Move deeper into the hierarchy for the children if this is not the last part
            current_level = current_level[part]["children"] unless index == path_parts.size - 1
          end
        end
      end
    end
  end
end
