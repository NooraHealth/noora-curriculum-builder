Template.lessonListItem.helpers
  modulesInLesson: ()->
    EditingModules.find {parent_lesson: @._id}


Template.addModuleModal.helpers {
  option: (index)->
    return {option: index}
}

Template.curriculumBuilder.helpers
  lessons: ()->
    currId = Session.get "curriculum"
    curriculum = Curriculum.findOne {_id: currId}
    return curriculum.getLessonDocuments()


  
