require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    # this avoid count customers that was already attended by another customers success
    last_customer_success_score = 0

    customer_success_with_count_of_attended_customers = available_customer_success.map.with_index do |available_cs, index|
      # filter customers and customers success
      customers_not_attended_yet = sorted_customers.select do |customer|
        customer[:score] > last_customer_success_score
      end

      customers_that_would_be_attended_by_available_cs = customers_not_attended_yet.select do |customer|
        customer[:score] <= available_cs[:score]
      end

      last_customer_success_score = available_cs[:score]

      [ available_cs[:id], customers_that_would_be_attended_by_available_cs.count ]
    end

    # group customers success that has the same number of customers attended
    customers_count_with_customer_success_ids = customer_success_with_count_of_attended_customers.group_by do |customer_success|
      customer_success.last
    end

    # select the group of customers success who has the maximum customers count
    customer_sucess_with_bigger_count = customers_count_with_customer_success_ids.max do |available_cs_a, available_cs_b|
      available_cs_a.first <=> available_cs_b.first
    end

    # extract customer success ids
    customer_success_ids_wich_attended_most_customers = customer_sucess_with_bigger_count.last.map(&:first)

    wich_costumer_success_attends_most?(customer_success_ids_wich_attended_most_customers)
  end

  private

  attr_reader :customer_success, :customers, :away_customer_success

  def available_customer_success
    @available_customer_success ||= filter_for_available_customer_success_and_sort
  end

  def filter_for_available_customer_success_and_sort
    available_cs = customer_success.reject do |cs|
      away_customer_success.include?(cs[:id])
    end

    available_cs.sort_by { |cs| cs[:score] }
  end

  def sorted_customers
    @sorted_customers ||= customers.sort_by do |customer|
      customer[:score]
    end
  end

  def wich_costumer_success_attends_most?(customer_success_ids_wich_attended_most_customers)
    return 0 if customer_success_ids_wich_attended_most_customers.count > 1

    customer_success_ids_wich_attended_most_customers.first
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10_000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  def test_scenario_eight
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 95, 75]),
      build_scores([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
