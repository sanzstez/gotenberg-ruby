require 'minitest/autorun'
require 'gotenberg/chromium/properties'

class ChromiumPropertiesTest < Minitest::Test
  class Harness
    include Gotenberg::Chromium::Properties

    def form_properties
      send(:properties)
    end
  end

  def setup
    @document = Harness.new
  end

  def test_wait_for_network_idle_enables_strict_network_idle_wait
    result = @document.wait_for_network_idle

    assert_same @document, result
    assert_equal false, @document.form_properties['skipNetworkIdleEvent']
  end

  def test_wait_for_network_almost_idle_enables_network_almost_idle_wait
    skip 'Implemented after merging strict network idle support'

    result = @document.wait_for_network_almost_idle

    assert_same @document, result
    assert_equal false, @document.form_properties['skipNetworkAlmostIdleEvent']
  end
end
