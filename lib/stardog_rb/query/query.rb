module Stardog
  # Query Stardog databases
  module Query
    class << self
      def remove_sparql_prologue(query)
        prefix_reg = /prefix[^:]+:\s*<[^>]*>\s*/i
        base_reg = /^((base\s+<[^>]*>\s*)|([\t ]*#([^\n\r]*)))([\r|\r\n|\n])/im

        query
          .gsub(prefix_reg, '')
          .gsub(base_reg, '')
          .gsub(/\s/, '')
          .downcase
      end

      def query_type(query)
        q = remove_sparql_prologue(query)

        type = %w[select ask construct describe].find { |t| q.start_with?(t) }
        return type if type

        update_types = %w[
          insert delete with load clear create drop copy move add
        ]
        return 'update' if update_types.any? { |t| q.start_with?(t) }

        return 'paths' if q.start_with?('paths')
      end

      def content_type(query)
        case query_type(query)
        when 'select', 'paths'
          'application/sparql-results+json'
        when 'ask', 'update'
          'text/boolean'
        when 'construct', 'describe'
          'text/turtle'
        else
          '*/*'
        end
      end

      def execute(conn, database, query, params = {})
        type = Query.query_type(query)
        resource = type == 'update' ? 'update' : 'query'
        content_type = params.delete('accept') || Query.content_type(query)
        request = conn.post_request(query, params, database, resource)
        request.content_type = "application/sparql-#{resource}"
        conn.response(request, content_type)
      end
    end
  end
end
