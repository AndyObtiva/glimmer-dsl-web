require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class TextProxy < WidgetProxy
      attr_reader :text, :border, :left, :center, :right, :read_only, :wrap, :multi
      alias border? border
      alias left? left
      alias center? center
      alias right? right
      alias read_only? read_only
      alias wrap? wrap
      alias multi? multi
      
      def initialize(parent, args, block)
        args << :border if args.empty?
        @border = !!args.detect { |arg| SWTProxy[arg] == SWTProxy[:border] }
        @left = !!args.detect { |arg| SWTProxy[arg] == SWTProxy[:left] }
        @center = !!args.detect { |arg| SWTProxy[arg] == SWTProxy[:center] }
        @right = !!args.detect { |arg| SWTProxy[arg] == SWTProxy[:right] }
        @read_only = !!args.detect { |arg| SWTProxy[arg] == SWTProxy[:read_only] }
        @wrap = !!args.detect { |arg| SWTProxy[arg] == SWTProxy[:wrap] }
        @multi = !!args.detect { |arg| SWTProxy[arg] == SWTProxy[:multi] }
        super(parent, args, block)
      end

      def text=(value)
        @text = value
        Document.find(path).value = value
      end
      
      def element
        @wrap || @multi ? 'textarea' : 'input'
      end
      
      def observation_request_to_event_mapping
        myself = self
        {
          'on_verify_text' => [
            {
              event: 'beforeinput',
              event_handler: -> (event_listener) {
                -> (event) {
                  event.define_singleton_method(:widget) {myself}
                  event.define_singleton_method(:text) {`#{event.to_n}.originalEvent.data` || ''}
                  selection_start = `#{event.target}[0].selectionStart`
                  selection_end = `#{event.target}[0].selectionEnd`
                  if `#{event.to_n}.originalEvent.inputType` == 'deleteContentBackward' && selection_start == selection_end
                    selection_start -= 1
                    selection_start = 0 if selection_start < 0
                  end
                  event.define_singleton_method(:start) do
                    selection_start
                  end
                  event.define_singleton_method(:end) {selection_end}
                  doit = true
                  event.define_singleton_method(:doit=) do |value|
                    doit = value
                  end
                  event.define_singleton_method(:doit) { doit }
                  event_listener.call(event)
                  
                  if !doit
                    `#{event.to_n}.originalEvent.returnValue = false`
                  end
                  
                  doit
                }
              }
            },
            {
              event: 'input',
              event_handler: -> (event_listener) {
                -> (event) {
                  event.define_singleton_method(:widget) {myself}
                  @text = event.target.value
                }
              }
            }
          ],
          'on_modify_text' => [
            {
              event: 'input',
              event_handler: -> (event_listener) {
                -> (event) {
                  # TODO add all attributes for on_modify_text modify event
                  event.define_singleton_method(:widget) {myself}
                  @text = event.target.value
                  event_listener.call(event)
                }
              }
            }
          ],
        }
      end
      
      def dom
        text_text = @text
        text_id = id
        text_style = 'min-width: 27px; '
        text_style += 'border: none; ' if !@border
        text_style += 'text-align: left; ' if @left
        text_style += 'text-align: center; ' if @center
        text_style += 'text-align: right; ' if @right
        text_class = name
        options = {type: 'text', id: text_id, style: text_style, class: text_class, value: text_text}
        options = options.merge('disabled': 'disabled') unless @enabled
        options = options.merge('readonly': 'readonly') if @read_only
        options = options.merge('contenteditable': 'true')
        options = options.merge(type: 'password') if has_style?(:password)
        @dom ||= html {
          send(element, options)
        }.to_s
      end
    end
  end
end
