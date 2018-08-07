module Graphiti
  class Renderer
    CONTENT_TYPE = 'application/vnd.api+json'

    attr_reader :proxy, :options

    def initialize(proxy, options)
      @proxy = proxy
      @options = options
    end

    def records
      @records ||= @proxy.data
    end

    def to_jsonapi
      render(JSONAPI::Renderer.new).to_json
    end

    def to_json
      render(Graphiti::HashRenderer.new(@proxy.resource)).to_json
    end

    def to_xml
      render(Graphiti::HashRenderer.new(@proxy.resource)).to_xml(root: :data)
    end

    private

    def render(implementation)
      notify do
        instance = JSONAPI::Serializable::Renderer.new(implementation)
        options[:fields] = proxy.fields
        options[:expose] ||= {}
        options[:expose][:extra_fields] = proxy.extra_fields
        options[:expose][:proxy] = proxy
        options[:include] = proxy.include_hash
        options[:meta] ||= {}
        options[:meta].merge!(stats: proxy.stats) unless proxy.stats.empty?
        instance.render(records, options)
      end
    end

    # TODO: more generic notification pattern
    # Likely comes out of debugger work
    def notify
      if defined?(ActiveSupport::Notifications)
        opts = [
          'render.graphiti',
          records: records,
          options: options
        ]
        ActiveSupport::Notifications.instrument(*opts) do
          yield
        end
      else
        yield
      end
    end
  end
end
