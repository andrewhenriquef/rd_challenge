require './src/validations/input'

class CustomerSuccessBalancing
  DRAW_RESPONSE = 0
  NOT_FOUND_RESPONSE = 0
  NO_CUSTOMER_SUCCESS_FOUND = 0
  ONE_CUSTOMER_SUCCESS_FOUND = 1

  include Validations::Input

  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  def execute
    return return_invalid_response if invalid_input?

    case amount_of_available_customers_success
    when ONE_CUSTOMER_SUCCESS_FOUND then return only_the_one_available_customer_success
    when NO_CUSTOMER_SUCCESS_FOUND then return NOT_FOUND_RESPONSE
    end

    return DRAW_RESPONSE if more_than_one_customer_success_attending_most?

    only_the_customer_success_that_attended_most
  end

  private

  attr_reader :customer_success, :customers, :away_customer_success

  def available_customer_success
    @available_customer_success ||= filter_for_available_customer_success
  end

  def amount_of_available_customers_success
    available_customer_success.count
  end

  def only_the_one_available_customer_success
    available_customer_success.first[:id]
  end

  def more_than_one_customer_success_attending_most?
    customers_success_that_attended_most.count > 1
  end

  def only_the_customer_success_that_attended_most
    customers_success_that_attended_most.first[:id]
  end

  def filter_for_available_customer_success
    available_cs = customer_success.reject do |cs|
      away_customer_success.include?(cs[:id])
    end

    customers_minimum_score = customers.min_by { |customer| customer[:score] }[:score]
    customers_maximum_score = customers.max_by { |customer| customer[:score] }[:score]

    available_cs.select do |cs|
      cs[:score] >= customers_minimum_score || cs[:score] >= customers_maximum_score
    end
  end

  def customers_success_that_attended_most
    @customer_success_that_attends_most_customers ||= customer_success_that_attends_most_customers.last
  end

  def customer_success_that_attends_most_customers
    sorted_available_customer_success = available_customer_success.sort_by do |available_cs|
      available_cs[:score]
    end

    previous_cs_score = 0

    available_cs_by_count_of_custumers_attended = sorted_available_customer_success.group_by do |available_cs|
      customer_attended_by_available_cs = customers.select do |customer|
        customer[:score] <= available_cs[:score] && customer[:score] > previous_cs_score
      end

      previous_cs_score = available_cs[:score]

      customer_attended_by_available_cs.count
    end

    available_cs_by_count_of_custumers_attended.max_by do |customers_attended, available_cs_group|
      customers_attended
    end
  end
end
