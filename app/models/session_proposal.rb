require 'elasticsearch/model'

class SessionProposal < ActiveRecord::Base
  include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks TBD!

  belongs_to :user
  has_many :comments
  has_and_belongs_to_many :tags

  def as_indexed_json options={}
    JSON.parse(Jbuilder.encode do |json|
      json.id           self.id
      json.title        self.title
      json.description  self.description
      json.author       self.user.full_name
      json.tags         self.tags.map(&:name)
    end)
  end

  def self.custom_search terms
    query = terms.blank? ? self.match_all_query : self.aggregated_query(terms)
    search query
  end

  def self.aggregated_query terms
    Jbuilder.encode do |json|
      json.query do
        json.multi_match do
          json.fields ["tags^10", "title^5", "description"]
          json.query terms
        end
      end
      json.highlight do
        json.fields do
          json.title "{}"
          json.description "{}"
        end
      end
      json.aggregations do
        json.matched_tags do
          json.terms do
            json.field "tags"
          end
        end
      end
    end
  end

  def self.match_all_query
    Jbuilder.encode do |json|
      json.query do
        json.match_all Hash.new
      end
    end
  end
end
