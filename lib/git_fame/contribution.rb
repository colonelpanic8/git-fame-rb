# frozen_string_literal: true

module GitFame
  class Contribution < Base
    attribute :lines, Types::Integer
    attribute :commits, Types::Set
    attribute :files, Types::Set
    attribute :author, Author
    attribute :lines_by_file, Hash

    delegate :name, :email, to: :author
  end
end
