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
    return 0 if invalid_ids? || invalid_scores?

    case available_customer_success.count
    when 1 then return available_customer_success.first[:id]
    when 0 then return 0
    end

    return 0 if customer_success_that_attended_most.count > 1

    customer_success_that_attended_most.first[:id]
  end

  private

  attr_reader :customer_success, :customers, :away_customer_success

  def available_customer_success
    @available_customer_success ||= filter_for_available_customer_success
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

  def customer_success_that_attended_most
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

  def invalid_ids?
    customer_success.any? { |cs| cs[:id].negative? || cs[:id].zero? || cs[:id] > 1_000_000 } ||
      customers.any? { |c| c[:id].negative? || c[:id].zero? || c[:id] > 10_000 }
  end

  def invalid_scores?
    customer_success.any? { |cs| cs[:score].negative? || cs[:score].zero? || cs[:score] > 10_000 } ||
      customers.any? { |c| c[:score].negative? || c[:score].zero? || c[:score] > 100_000 }
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

  def test_scenario_nine
    balancer = CustomerSuccessBalancing.new(
      build_scores_with_negative_ids([60, 40, 95, 75]),
      build_scores([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )

    assert_equal 0, balancer.execute
  end

  def test_scenario_ten
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 95, 75]),
      build_scores_with_negative_ids([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )

    assert_equal 0, balancer.execute
  end

  def test_scenario_eleven
    balancer = CustomerSuccessBalancing.new(
      build_negative_scores([60, 40, 95, 75]),
      build_scores([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )

    assert_equal 0, balancer.execute
  end

  def test_scenario_twelve
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 95, 75]),
      build_negative_scores([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )

    assert_equal 0, balancer.execute
  end

  private

  def build_scores_with_negative_ids(scores)
    scores.map.with_index do |score, index|
      { id: -index, score: score }
    end
  end

  def build_negative_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: -score }
    end
  end

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
