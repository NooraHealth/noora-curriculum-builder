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

Template.curriculumBuilder.helpers
  curriculumTitle: ()->
    curr = Meteor.getCurrentCurriculum()
    return curr.title
  curriculumCondition: ()->
    curr = Meteor.getCurrentCurriculum()
    return curr.condition
  lessons: ()->
    curriculum = Meteor.getCurrentCurriculum()
    return curriculum.getLessonDocuments()

Tracker.autorun ()->
  error = Session.get "error-message"
  Materialize.toast
