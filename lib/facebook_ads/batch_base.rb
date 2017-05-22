module FacebookAds
  module BatchBase
    def self.included base
      base.instance_eval do
        
        def batch( verb, path, query, objectify )
          @batch_queries ||= []        
          @batch_queries << {"method" => verb, "relative_url" => path, "body" => build_nested_query( query )}
        end
        
        def get(path, query: {}, objectify:)
          batch( 'GET', path, query, objectify )
        end

        def post(path, query: {})
          batch( 'POST', path, query, false )
        end

        def delete(path, query: {})
          batch( 'DELETE', path, query, false )
        end
        
        def run_batch
          query = pack({batch: @batch_queries.to_json}, objectify: true) # Adds access token, fields, etc.
          uri = "#{FacebookAds.base_uri}"
          responses = begin
                        RestClient.post(uri, query)
                      rescue RestClient::Exception => e
                        exception(:post, '/', e)
                      end
          
          to_return = []
          JSON.parse(responses.body).each do |response|
            to_return << unpack(response, objectify: true )
          end
          to_return
        end
      end
    end
  end    
end

