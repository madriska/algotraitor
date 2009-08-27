module Algotraitor
  module Extension
    
    class TradeHistory
      
      def self.after_trade(options)
        history << options
      end

      def self.history
        @history ||= []
      end

      def self.to_json
        history.map do |trade|
          {
            'participant_id' => trade[:participant].id,
            'time' => trade[:time],
            'stock' => trade[:stock].symbol,
            'price' => trade[:price],
            'quantity'=> trade[:quantity]
          }
        end.to_json
      end

    end

  end
end
