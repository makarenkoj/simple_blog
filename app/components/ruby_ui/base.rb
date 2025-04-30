module RubyUI
  unless const_defined?(:Base)
    class Base < Phlex::HTML
      include RubyUI
      include Phlex::Rails::Helpers::ContentFor

      delegate :link_to, :content_for, :csrf_meta_tags, :t, :l, :safe_join, :html_safe,
               :user_signed_in?, :current_user, :current_user_can_edit?,
               :root_path, :new_post_path, :destroy_user_session_path, :new_user_session_path, :new_user_registration_path,
               :post_path, :edit_post_path, :posts_path, :user_path,
               :flash,
               to: :view_context

      TAILWIND_MERGER = ::TailwindMerge::Merger.new.freeze unless defined?(TAILWIND_MERGER)

      attr_reader :attrs, :view_context

      def initialize(view_context: nil, **user_attrs)
        @view_context = view_context
        super(**user_attrs)
        @attrs ||= {}
        @attrs.merge!(mix(default_attrs, user_attrs)) # Правильне злиття після super
        @attrs[:class] = TAILWIND_MERGER.merge(@attrs[:class]) if @attrs[:class]
      end

      private

      def default_attrs
        {}
      end
    end
  end
end
