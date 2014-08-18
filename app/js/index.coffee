Bacon = require 'src/bacon'
Stats = require "js/fps"


stats = 0
renderer = 0
stage = 0
map = 0
wWidth = $(window).width()
wHeight = $(window).height()



draw = () ->
  stats.begin()
  renderer.render(stage)
  requestAnimationFrame(draw)
  stats.end()


xyFromEvent = (v) -> [v.clientX, v.clientY]

getDelta = (t) ->
  a = t[1]
  b = t[0]
  [a[0]-b[0], a[1]-b[1]]

add = (p1, p2) ->
  [p1[0] + p2[0], p1[1] + p2[1]]




mapInit = () ->
####################
  stats = new Stats()
  stats.setMode(0)
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.left = '0px'
  stats.domElement.style.top = '0px'
  document.body.appendChild( stats.domElement )
#####################

  renderer = new PIXI.CanvasRenderer(wWidth, wHeight, document.querySelector(".map"))
  stage = new PIXI.Stage
  mapTexture = PIXI.Texture.fromImage('map_small.jpg')
  map = new PIXI.Sprite(mapTexture)
  window.map = map
  map.anchor.x = 0.5
  map.anchor.y = 0.5


  stage.addChild(map)
  do draw



  In = $(".plus").asEventStream('click')
  Out = $(".minus").asEventStream('click')
  zoom = In.map(1.25).merge(Out.map(0.8)).scan 0.5, (x,y) ->
    newZoom = Math.round(x*y*10)/10
    if newZoom < 0.5
      newZoom = 0.5
    else if newZoom > 2
      newZoom =2
    newZoom


  zoom.assign $(".zoom"), 'text'
  zoom.onValue (x) ->
    map.scale.x = x
    map.scale.y = x
    requestAnimationFrame(draw)

  canvas = $(".map")
  dragging = canvas.asEventStream('mousedown')
    .map(true)
    .merge(canvas.asEventStream('mouseup')
    .map(false))
    .toProperty(false)
  deltas = canvas.asEventStream('mousemove')
    .map(xyFromEvent)
    .slidingWindow(2,2)
    .map(getDelta)

  draggingDeltas = Bacon.combineWith( (delta, dragging) ->
    if (!dragging)
      return [0, 0]
    delta
  , deltas, dragging)

  blockPosition = draggingDeltas.scan([wWidth/2,wHeight/2], add)
  blockPosition.onValue (pos) ->
    map.position.x = pos[0]
    map.position.y = pos[1]









$(document).ready ->
  do mapInit

$(window).resize ->







