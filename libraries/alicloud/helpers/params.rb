# frozen_string_literal: true

module AliCloud
  module Helpers
    module Params
      private

      def querystring_from(opts, action, params)
        params = prepare_params(opts, action, params)
        normalized = normalize_params_for(params)
        canonicalize(normalized)
      end

      def prepare_params(opts, action, params)
        action = upcase_first(action) if opts[:format_action]
        params = format_params(params) unless opts[:format_params]
        defaults = default_params
        { Action: action }.merge(defaults).merge(params)
      end

      def normalize_params_for(params)
        normalized = normalize(params)
        string_to_sign = generate_string_to_sign(http_method, normalized)
        signature = generate_signature(string_to_sign)
        normalized.push(['Signature', encode(signature)])
        normalized
      end

      def add_default_params(params, action)
        { Action: action }.merge(default_params).merge(params)
      end

      # Converts just the first character to uppercase.
      def upcase_first(string)
        string.camelize
      end

      def generate_string_to_sign(method, normalized)
        "#{method}&#{encode('/')}&#{encode(canonicalize(normalized))}"
      end

      def canonicalize(normalized)
        normalized.map { |element| "#{element.first}=#{element.last}" }.join('&')
      end

      def encode(string)
        encoded = CGI.escape(string.to_s)
        encoded.gsub(/\+/, '%20')
      end

      def format_params(param_hash)
        param_hash.transform_keys { |key| upcase_first(key.to_s).to_sym }
      end

      # def format_params(param_hash)
      #   param_hash.transform_keys { |key| upcase_first(key.to_s).to_sym }
      # end

      def replace_repeat_list(target, key, repeat)
        repeat.each_with_index do |item, index|
          if item.instance_of?(Hash)
            item.each_key { |k| target["#{key}.#{index.next}.#{k}"] = item[k] }
          else
            target["#{key}.#{index.next}"] = item
          end
        end
        target
      end

      def flat_params(params)
        target = {}
        params.each do |key, value|
          if value.instance_of?(Array)
            replace_repeat_list(target, key, value)
          else
            target[key.to_s] = value
          end
        end
        target
      end

      def normalize(params)
        flat_params(params)
          .sort
          .to_h
          .map { |key, value| [encode(key), encode(value)] }
      end

      def validate(config)
        raise ArgumentError, 'must pass "config"' unless config
        raise ArgumentError, 'must pass "config[:endpoint]"' unless config[:endpoint]
        unless config[:endpoint].start_with?('http://') || config[:endpoint].start_with?('https://')
          raise ArgumentError, '"config.endpoint" must start with \'https://\' or \'http://\'.'
        end
        raise ArgumentError, 'must pass "config[:api_version]"' unless config[:api_version]
        raise ArgumentError, 'must pass "config[:access_key_id]"' unless config[:access_key_id]
        raise ArgumentError, 'must pass "config[:access_key_secret]"' unless config[:access_key_secret]
      end
    end
  end
end
