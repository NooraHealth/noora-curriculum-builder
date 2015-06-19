Template.lessonListItem.helpers
  modulesInLesson: ()->
    lesson = @
    console.log "This is the lesson"
    console.log @
    return @.getModulesSequence()

Template.addModuleModal.helpers {
  option: (index)->
    return {option: index}
}

Template.moduleListItem.onDestroyed ()->
  console.log "Module list item destroyed!"
  console.log this

Template.curriculumBuilder.helpers
  lessons: ()->
    curriculum = Meteor.getStubCurriculum()
    return curriculum.getLessonDocuments()

Tracker.autorun ()->
  errorMessage = Session.get "error-message"
  Materialize.toast(errorMessage, 4000)
  
