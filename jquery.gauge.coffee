(($) ->

  defaults =
    min: 0
    max: 10
    current: 0
    lineWidth: 0.6

  class Gauge
    constructor: (options) ->
      settings = $.extend({}, defaults, options)
      @min = settings.min
      @max = settings.max
      @current = settings.current
      @element = settings.element
      @lineWidth = settings.lineWidth
      @$element = $(@element)
      @height = @$element.height()
      @width = @$element.width()
      @fillStyleColor = @$element.css('color')
      @fillStyleBackground = @$element.css('background-color')

      @createCanvas()
      @draw()

    createCanvas: ->
      # Construct the canvas element.
      @$canvas = $('<canvas>')
      @$canvas.height(@height).width(@width)
      @$canvas.attr('height', @height).attr('width', @width)
      @$canvas.appendTo(@$element)
      # Get the context and set some styles on it matching the @element.
      @context = @$canvas[0].getContext('2d')
      @context.font = @$element.css('font')
      @context.textAlign = 'center'
      @context.textBaseline = 'middle'
      @context.fillStyle = @context.strokeStyle = @fillStyleColor
      # Find out if our background color works.
      @detectBackground()

    detectBackground: ->
      bgcolorFound = false
      bgcolor = @fillStyleBackground
      $currentElem = @$element
      until bgcolorFound
        @context.fillStyle = bgcolor
        # Draw a pixel using the current background color.
        @context.fillRect(0, 0, 1, 1)
        # Grab the pixel data for that pixel.
        pixelData = @context.getImageData(0, 0, 1, 1)
        # Is the background transparent?
        # RGBA, R = 0, G = 1, etc... We want alpha.
        bgAlpha = pixelData.data[3]
        if bgAlpha == 0
          # If so, walk up to the parent element, grab its bgcolor, and try again.
          $currentElem = $currentElem.parent()
          bgcolor = $currentElem.css('background-color')
        else
          # If not, we're done.
          bgcolorFound = true
          @fillStyleBackground = bgcolor

    draw: ->
      # Calculate everything.
      ratio = @current / (@max - @min)
      # Clamp the ratio.
      ratio = 0 if ratio < 0
      ratio = 1 if ratio > 1
      arcLength = ratio * 2 * Math.PI
      centerX = @width / 2
      centerY = @height / 2
      radius = @width / 3
      @context.lineWidth = radius * @lineWidth
      startPoint = -(Math.PI / 2)
      # Subtract Math.PI/2 to rotate -90 degrees...
      arcLength += startPoint
      # Erase everything.
      @context.fillStyle = @fillStyleBackground
      @context.fillRect(0, 0, @width, @height)
      # Draw the arc.
      @context.fillStyle = @fillStyleColor
      @context.beginPath()
      @context.arc(centerX, centerY, radius, startPoint, arcLength)
      @context.stroke()
      # Draw the text in the middle.
      @context.fillText('' + @current, centerX, centerY)

    redraw: (current, max) ->
      @current = current
      @max = max
      @draw()


  $.fn.gauge = (options, args...) ->
    @each ->
      # Did we get sent options for a new gauge?
      # Or did we get sent a method invocation on an old one?
      if typeof options == 'string'
        # Is there already a gauge here?
        gauge = $.data(@, 'gauge')
        if not gauge
          console.warn 'Attempted to get gauge where there was none.'
        if options == 'redraw'
          gauge.redraw(args...)
      else if typeof options == 'object'
        options =
          min: options.min
          max: options.max
          current: options.current
          lineWidth: options.lineWidth
          element: @
        gauge = new Gauge(options)
        $.data(@, 'gauge', gauge)
)(jQuery)
