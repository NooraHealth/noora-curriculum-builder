Meteor.methods {
  updateCurriculum: (id, data)->
    Curriculum.update {_id: id}, {$set:{title: data.title, lessons:data.lessons, contentSrc: data.contentSrc, condition: data.condition}}, (err, doc)->
      if err
        throw new Meteor.Error "mongo-error", err

  removeStubCurriculum:()->
    Curriculum.remove {title: TITLE_OF_STUB}

  deleteLesson: (id)->
    console.log "Deleting the lesson"
    check(id, String)
    lesson = Lessons.findOne {_id: id}
    if !lesson
      throw new Meteor.Error "document-not-found", "Lesson to delete could not be found"
    #delete the modules
    Meteor.call "removeAllModules", lesson
    #delete the lesson
    Lessons.remove {_id: id}
    #remove from curriculum
    curriculum = Meteor.getStubCurriculum()
    if !curriculum
      throw new Meteor.Error "document-not-found", 'The current editing curriculum could not be found'
    lessons= curriculum.lessons
    newLessons = (lesson for lesson in lessons when lesson != id)
    Curriculum.update {_id: curriculum._id}, {$set: {lessons: newLessons}}, (err)->
      if err
        throw new Meteor.Error 'mongo-error', err
        console.log "Error updating curriculum:", err

  deleteModule: (id, parent)->
    check id, String
    check parent, String
    lesson = Lessons.findOne {_id:parent}
    modules = lesson.modules
    newModules = (module for module in modules when module != id)
    Lessons.update {_id: parent}, {$set:{modules: newModules}}, (err)->
      if err
        throw new Meteor.Error "mongo-error", err
        console.log "Error updating lesson:", err
        
    Modules.remove {_id:id}, (err)->
      if err
        throw new Meteor.err "mongo-Error", err
        console.log "Error removing module:", err

  removeAllModules: (lesson)->
    if !lesson or !lesson.modules
      throw new Meteor.Error "document-not-found", "Error removing modules"
    for module in lesson.modules
      Modules.remove {_id:module}, (err)->
        if err
          throw new Meteor.Error "mongo-err", err
          console.log "Error removing module:", err

  appendModule: (lessonId, moduleId)->
    check(lessonId, String)
    check(moduleId, String)
    Lessons.update {_id: lessonId}, {$push: {"modules":moduleId}}, (err)->
      if err
        throw new Meteor.Error 'mongo-error', err
        console.log "Error updating lesson:", err

  appendLesson: ( curriculumId, lessonId)->
    check curriculumId, String
    check lessonId, String
    Curriculum.update {_id: curriculumId}, {$push: {"lessons":lessonId}}, (err)->
      if err
        throw new Meteor.Error 'mongo-error', err
        console.log "Error updating curriculum:", err

  getBucket: ()->
    if process.env.METEOR_ENV == 'production'
      return BUCKET
    else
      return DEV_BUCKET

  contentEndpoint: ()->
    if process.env.METEOR_ENV == 'production'
      return "https://noorahealthcontent.s3-us-west-1.amazonaws.com/"
    else
      return 'https://noorahealth-development.s3-us-west-1.amazonaws.com/'

}
