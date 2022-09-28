module Gotenberg
  module Utilities
    class Index
      def self.to_alpha index, alpha = ''
        return '' if index <= 0

        until index.zero?
          pointer = (index - 1) % 26
          index = ((index - pointer) / 26).to_i
          alpha = (65 + pointer).chr + alpha
        end
        
        alpha
      end
    end
  end
end