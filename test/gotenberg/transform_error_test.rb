require 'minitest/autorun'
require 'faraday'
require 'gotenberg/exceptions'

class TransformErrorTest < Minitest::Test
  HTTP_RESPONSE = {
    status: 400,
    headers: { 'content-type' => 'application/json' },
    body: '{"message":"invalid input"}'
  }.freeze

  def test_retains_http_response_details
    original_error = Faraday::BadRequestError.new(HTTP_RESPONSE)

    error = Gotenberg::TransformError.new(original_error)

    assert_equal original_error.message, error.message
    assert_same original_error, error.original_error
    assert_same HTTP_RESPONSE, error.response
    assert_equal 400, error.response_status
    assert_equal({ 'content-type' => 'application/json' }, error.response_headers)
    assert_equal '{"message":"invalid input"}', error.response_body
  end

  def test_transport_error_has_no_response_details
    original_error = Faraday::ConnectionFailed.new('connection failed')

    error = Gotenberg::TransformError.new(original_error)

    assert_equal 'connection failed', error.message
    assert_same original_error, error.original_error
    assert_nil error.response
    assert_nil error.response_status
    assert_nil error.response_headers
    assert_nil error.response_body
  end

  def test_string_construction_remains_supported
    original_error = 'transformation failed'

    error = Gotenberg::TransformError.new(original_error)

    assert_equal 'transformation failed', error.message
    assert_same original_error, error.original_error
    assert_nil error.response
    assert_nil error.response_status
    assert_nil error.response_headers
    assert_nil error.response_body
  end

  def test_zero_argument_construction_and_raising_remain_supported
    constructed_error = Gotenberg::TransformError.new
    raised_error = assert_raises(Gotenberg::TransformError) { raise Gotenberg::TransformError }

    [constructed_error, raised_error].each { |error| assert_empty_transform_error(error) }
  end

  private

  def assert_empty_transform_error(error)
    assert_equal 'Gotenberg::TransformError', error.message
    assert_nil error.original_error
    assert_nil error.response
    assert_nil error.response_status
    assert_nil error.response_headers
    assert_nil error.response_body
  end
end
