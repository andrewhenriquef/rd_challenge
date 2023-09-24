
module Validations
  module Input
    INVALID_INPUT = 0

    def invalid_input?
      invalid_ids? || invalid_scores?
    end

    def return_invalid_response
      INVALID_INPUT
    end

    def invalid_ids?
      customer_success.any? { |cs| cs[:id] <= 0 || cs[:id] > 1_000_000 } ||
        customers.any? { |c| c[:id] <= 0 || c[:id] > 10_000 }
    end

    def invalid_scores?
      customer_success.any? { |cs| cs[:score] <= 0 || cs[:score] > 10_000 } ||
        customers.any? { |c| c[:score] <= 0 || c[:score] > 100_000 }
    end
  end
end