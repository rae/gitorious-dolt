# encoding: utf-8
#--
#   Copyright (C) 2012-2013 Gitorious AS
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
require "dolt/sinatra/repo_browser"
require "libdolt/view/single_repository"

module Dolt
  module Sinatra
    class SingleRepoBrowser < RepoBrowser
      include Dolt::View::SingleRepository

      def self.ref_path_pattern(action)
        %r{/#{action}/([^:]+)(?::|%3(?:a|A))(.*)}
      end

      def initialize(repo, lookup, renderer)
        @repo = repo
        super(lookup, renderer)
      end

      get "/" do
        redirect("/tree/HEAD:")
      end

      get ref_path_pattern('tree') do |ref, path| # "/tree/*:*
        begin
          dolt.tree(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/tree/*" do
        dolt.force_ref(params[:splat], "tree", "HEAD")
      end

      get ref_path_pattern('blob') do |ref, path| # "/blob/*:*
        begin
          dolt.blob(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/blob/*" do
        dolt.force_ref(params[:splat], "blob", "HEAD")
      end

      get ref_path_pattern('raw') do |ref, path| # "/raw/*:*
        begin
          dolt.raw(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/raw/*" do
        dolt.force_ref(params[:splat], "raw", "HEAD")
      end

      get ref_path_pattern('blame') do |ref, path| # "/blame/*:*
        begin
          dolt.blame(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/blame/*" do
        dolt.force_ref(params[:splat], "blame", "HEAD")
      end

      get ref_path_pattern('history') do |ref, path| # "/history/*:*
        begin
          dolt.history(repo, ref, path, (params[:commit_count] || 20).to_i)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/history/*" do
        dolt.force_ref(params[:splat], "blame", "HEAD")
      end

      get "/refs" do
        begin
          dolt.refs(repo)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get ref_path_pattern('tree_history') do |ref, path| # "/tree_history/*:*
        begin
          dolt.tree_history(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      private

      attr_reader :repo

      def force_ref(args, action, ref)
        redirect("/#{action}/#{ref}:" + args.join)
      end
    end
  end
end
