# encoding: utf-8
#--
#   Copyright (C) 2012 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
require "dolt/async/when"
require "dolt/git/blob"

module Dolt
  module Git
    class Repository
      attr_reader :name

      def initialize(name, git = nil)
        @name = name
        @git = git
      end

      def blob(path, ref = "HEAD")
        gitop = git.show(path, ref)
        deferred = When::Deferred.new

        gitop.callback do |data, status|
          deferred.resolve(Dolt::Blob.new(path, data))
        end

        gitop.errback { |err| deferred.reject(err) }
        deferred.promise
      end

      private
      def git; @git; end
    end
  end
end