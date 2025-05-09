module ActionText
  class BlobComponent < RubyUI::Base
    attr_reader :blob, :in_gallery

    def initialize(blob:, in_gallery: false, view_context: nil)
      super(view_context: view_context) if view_context
      @blob = blob
      @in_gallery = in_gallery
    end

    def template
      figure(class: "attachment attachment--#{blob.representable? ? 'preview' : 'file'} attachment--#{blob.filename.extension}") do
        if blob.representable?
          unsafe_raw view_context.image_tag(
            blob.representation(resize_to_limit: in_gallery ? [800, 600] : [1024, 768])
          )
        end

        figcaption(class: 'attachment__caption') do
          caption = blob.try(:caption)
          if caption.present?
            text caption
          else
            span(class: 'attachment__name') { text blob.filename }
            span(class: 'attachment__size') do
              text view_context.number_to_human_size(blob.byte_size)
            end
          end
        end
      end
    end
  end
end
