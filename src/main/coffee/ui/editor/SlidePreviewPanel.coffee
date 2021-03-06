###
@author Matt Crinklaw-Vogt
###
define(["vendor/amd/backbone",
		"./SlideSnapshot",
		"vendor/amd/keymaster",
		"ui/interactions/CutCopyPasteBindings",
		"model/system/Clipboard",
		"./SlideCopyPaste",
		"css!./css/SlidePreviewPanel.css"],
(Backbone, SlideSnapshot, Keymaster, CutCopyPasteBindings, Clipboard, SlideCopyPaste, empty) ->
	Backbone.View.extend(
		className: "slidePreviewPanel"
		events:
			"sortstop": "sortstop"
			"click": "clicked"

		initialize: () ->
			slideCollection = @model.get("slides")
			slideCollection.on("add", @_slideCreated, @)
			slideCollection.on("reset", @_slidesReset, @)

			# Set up keymaster events
			_.extend(@, SlideCopyPaste)
			CutCopyPasteBindings.applyTo(@, "slidePreviewPanel")
			@_clipboard = new Clipboard()

		_slideCreated: (slide, collection, options) ->
			snapshot = new SlideSnapshot({model: slide, deck: @model})
			snapshot.on("removeClicked", @slideRemoveClicked, @)

			if options?
				$children = @$el.children()
				if $children.length > 0 and options.index < $children.length
					$children.eq(options.index).before(snapshot.render())
				else
					@$el.append(snapshot.render())
			else
				@$el.append(snapshot.render())

		_slidesReset: (newSlides) ->
			newSlides.each((slide) =>
				@_slideCreated(slide)
			)

		_slideRemoved: (slide, collection, options) ->
			@snapshots[options.index].remove()
			@snapshots.splice(options.index, 1)

		slideRemoveClicked: (snapshot) ->
			@model.removeSlide(snapshot.model)

		render: () ->
			slides = @model.get("slides")
			if slides?
				slides.each((slide) =>
					@_slideCreated(slide)
				)

			@$el.sortable()
			@$el

		sortstop: (e, ui) ->
			@$el.children().each((idx, elem) =>
				$(elem).data("jsView").model.set("num", idx)
			)
			@model.get("slides").sort({silent: true})

		clicked: () ->
			if Keymaster.getScope() isnt "slidePreviewPanel"
				Keymaster.setScope("slidePreviewPanel")

		remove: () ->
			Backbone.View.prototype.remove.apply(this, arguments)
			@dispose()

		dispose: () ->
			@snapshots.forEach((snapshot) ->
				snapshot.dispose()
			)
	)
)