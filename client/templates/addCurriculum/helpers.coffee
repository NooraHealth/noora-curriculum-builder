Template.lessonListItem.helpers
  modulesInLesson: ()->
    lesson = @
    return @.getModulesSequence()

Template.addModuleModal.helpers {
  option: (index)->
    return {option: index}
}

Template.curriculumBuilder.helpers
  lessons: ()->
    curriculum = Meteor.getStubCurriculum()
    return curriculum.getLessonDocuments()


  
