# frozen_string_literal: true

module GitFame
  class Collector
    extend Dry::Initializer

    option :filter, type: Filter
    option :diff, type: Types::Any

    # @return [Collector]
    def call
      Result.new(contributions: contributions)
    end

    private

    def contributions
      commits = Hash.new { |h, k| h[k] = Set.new }
      files = Hash.new { |h, k| h[k] = Set.new }
      lines = Hash.new(0)
      names = {}
      lines_by_file = Hash.new { |h, k| h[k] = Hash.new(0) }

      diff.each do |change|
        filter.call(change) do |loc, file, oid, name, email|
          commits[email].add(oid)
          files[email].add(file)
          names[email] = name
          lines[email] += loc
          lines_by_file[email][file] += loc
        end
      end

      lines.each_key.map do |email|
        Contribution.new({
          lines: lines[email],
          commits: commits[email],
          files: files[email],
          lines_by_file: lines_by_file[email],
          author: {
            name: names[email],
            email: email
          }
        })
      end
    end
  end
end
