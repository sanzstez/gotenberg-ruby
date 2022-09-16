module Gotenberg
  module Extractors

    private 
    
    def extract_metadata_from_body body, variables = {}
      body.match('<title.*?>(.*?)<\/title>') do
        variables.merge!(title: $1)
      end

      variables
    end
  end
end