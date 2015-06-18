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
  lessons: ()->
    curriculum = Meteor.getStubCurriculum()
    return curriculum.getLessonDocuments()


  
