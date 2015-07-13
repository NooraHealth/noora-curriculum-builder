###
# Event handlers for selecting and deleting curriculum.
# Templates involved: selectCurriculum in selectCurriculum.html
###

Template.selectCurriculum.events {
  # Delete curriculum
  "click .delete-curriculum": (event, template)->
    event.preventDefault()
    curriculumId = $(event.target).parent().prev().prev().val()
    Meteor.call "deleteCurriculum", curriculumId
  
  # Select curriculum, routes to home
  "click #selectCurriculum":(event, template) ->
    curriculumId = $("input[name=curriculum]:checked").val()
    Meteor.setCurrentCurriculum curriculumId
    Router.go "home"
}

#Template.selectCurriculum.onRendered ()->
#  console.log "Select curriculum rendered"

