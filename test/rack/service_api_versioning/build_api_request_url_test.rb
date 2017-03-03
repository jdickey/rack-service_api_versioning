# frozen_string_literal: true

require 'test_helper'

require 'rack/service_api_versioning/build_api_request_url'

describe 'Rack::ServiceApiVersioning::BuildApiRequestUrl' do
  let(:described_class) { Rack::ServiceApiVersioning::BuildApiRequestUrl }

  describe 'has a .call method that' do
    let(:avida_sbu) { 'http://localhost:9292/api/apidemo/' }
    let(:apiver_sbu) { 'http://localhost:9876/v1/' }
    let(:request_url) { avida_sbu + request_frag }
    let(:call_params) do
      { api_version_sbu: apiver_sbu, avida_sbu: avida_sbu,
        request_url: request_url }
    end

    describe 'with no query parameters' do
      let(:request_frag) { 'dunsel/42/' }

      it 'returns the request URL substituting the API SBU for the AVIDA SBU' do
        actual = described_class.call call_params
        expect(actual).must_equal apiver_sbu + request_frag
      end
    end # describe 'with no query parameters'

    describe 'with query parameters' do
      let(:request_frag) { 'dunsel/42/?foo=true&bar=42' }

      it 'returns the request URL substituting the API SBU for the AVIDA SBU' do
        actual = described_class.call call_params
        expect(actual).must_equal apiver_sbu + request_frag
      end
    end # describe 'with query parameters'

    describe 'with a request URL that does not match the AVIDA SBU because' do
      describe 'the host name differs' do
        let(:request_url) { 'http://www.example.com/apidemo/whatever' }

        it 'returns the offending request URL' do
          actual = described_class.call call_params
          expect(actual).must_equal request_url
        end
      end # describe 'the host name differs'

      describe 'the port numbers differ' do
        let(:request_url) { 'http://localhost:1234/api/apidemo/whatever' }

        it 'returns the offending request URL' do
          actual = described_class.call call_params
          expect(actual).must_equal request_url
        end
      end # describe 'the port numbers differ'

      describe 'the base URL differs after the hostname' do
        let(:request_url) { 'http://localhost:9292/api/apiwhoops/whatever' }

        it 'returns the offending request URL' do
          actual = described_class.call call_params
          expect(actual).must_equal request_url
        end
      end
    end # describe 'with a request URL that does not match the AVIDA SBU ...'
  end # describe 'has a .call method that'
end
