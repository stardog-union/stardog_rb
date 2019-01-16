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
        when 'ask'
          'text/boolean'
        when 'construct', 'describe'
          'text/turtle'
        else
          '*/*'
        end
      end

      def extract_query_response(response, query_type, content_type)
        if content_type.include? 'json'
          Stardog::Connection.extract_json(response)
        elsif content_type.include? 'boolean'
          response == 'true'
        elsif query_type == 'update'
          :ok
        else
          response
        end
      end

      def execute(conn, database, query, params = {})
        type = Query.query_type(query)
        resource = type == 'update' ? 'update' : 'query'
        content_type = params.delete('accept') || Query.content_type(query)
        transaction_id = params.delete('transaction_id')
        request = conn.post_request(
          query, params, *[database, transaction_id, resource].compact
        )
        request.content_type = "application/sparql-#{resource}"
        response = conn.response(request, content_type).body
        extract_query_response(response, type, content_type)
      end

      def add(conn, database, transaction_id, content, params = {})
        content_type = params.delete('content_type') || 'text/turtle'
        encoding = params.delete('encoding')
        request = conn.post_request(
          content, params, database, transaction_id, 'add'
        )
        request.content_type = content_type
        request['Content-Encoding'] = encoding if encoding
        conn.response(request, '*/*')
        :ok
      end

      def remove(conn, database, transaction_id, content, params = {})
        content_type = params.delete('content_type') || 'text/turtle'
        encoding = params.delete('encoding')
        request = conn.post_request(
          content, params, database, transaction_id, 'remove'
        )
        request.content_type = content_type
        request['Content-Encoding'] = encoding if encoding
        conn.response(request, '*/*')
        :ok
      end
    end
  end
end
