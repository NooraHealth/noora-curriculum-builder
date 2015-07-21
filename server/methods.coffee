###
# Server-side Method Calls
###

Meteor.methods {
  deleteLessonFromS3: (lessonId, deleteFromLesson)->
    lesson = Lessons.findOne({_id: lessonId})
    objects = []
    if lesson.image? and ("image" in deleteFromLesson)
      objects.push {Key: lesson.image}
    if lesson.icon? and ("icon" in deleteFromLesson)
      objects.push {Key: lesson.icon}
    console.log "objects is"
    console.log objects
    if objects.length > 0
      s3.deleteObjects {Delete: {Objects: objects} }, (err, data)->
        if err
          console.log err
        else
          console.log data
    return
  
  deleteModuleFromS3: (moduleId, deleteFromModule)->
    module = Modules.findOne({_id: moduleId})
    objects = []
    if module.image? and ("image" in deleteFromModule)
      objects.push {Key: module.image}
    if module.audio? and ("audio" in deleteFromModule)
      objects.push {Key: module.audio}
    if module.incorrect_audio? and ("incorrectAudio" in deleteFromModule)
      objects.push {Key: module.incorrect_audio}
    if module.correct_audio? and ("correctAudio" in deleteFromModule)
      objects.push {Key: module.correct_audio}
    if module.video? and ("video" in deleteFromModule)
      objects.push {Key: module.video}
    console.log "objects is"
    console.log objects
    if objects.length > 0
      s3.deleteObjects {Delete: {Objects: objects} }, (err, data)->
        if err
          console.log err
        else
          console.log data
    return
  
  deleteCurriculum: (curriculumId)->
    curriculum = Curriculum.findOne {_id: curriculumId}
    lessons = curriculum.lessons
    for lesson in lessons 
      Meteor.call "deleteLesson", lesson, curriculumId, lessonFiles, moduleFiles
    Curriculum.remove {_id: curriculumId}, (err)->
      if err
        throw new Meteor.Error "mongo-error", err

  # Takes in a curriculum id and data object and updates curriculum to match the data. If the update fails, an error is thrown. 
  updateCurriculum: (curriculumId, data)->
    Curriculum.update {_id: curriculumId}, {$set:{title: data.title, lessons:data.lessons, contentSrc: data.contentSrc, condition: data.condition}}, (err)->
      if err
        throw new Meteor.Error "mongo-error", err

  # Removes the stub curriculum.
  removeStubCurriculum:()->
    Curriculum.remove {title: TITLE_OF_STUB}

  # Takes in a lesson id and deletes all the modules and the lesson. The curriculum is then updated. 
  # If lesson or curriculum documents are not found or if update fails, an error is thrown.
  deleteLesson: (lessonId, curriculumId, deleteFromLesson, deleteFromModule)->
    check(lessonId, String)
    console.log "deleteFromlLesson"
    console.log deleteFromLesson
    console.log "deleteFromModule"
    console.log deleteFromModule
    lesson = Lessons.findOne {_id: lessonId}
    if !lesson
      throw new Meteor.Error "document-not-found", "Lesson to delete could not be found"
    
    if deleteFromLesson.length > 0
      Meteor.call "deleteLessonFromS3", lessonId, deleteFromLesson
   
    #delete the modules
    Meteor.call "removeAllModules", lesson, deleteFromModule
    
    #delete the lesson
    Lessons.remove {_id: lessonId}
    console.log "deleted lesson"

    #remove from curriculum
    curriculum = Curriculum.findOne {_id: curriculumId}
    
    if !curriculum
      throw new Meteor.Error "document-not-found", 'The current editing curriculum could not be found'
    
    lessons = curriculum.lessons
    newLessons = (lesson for lesson in lessons when lesson != lessonId)
    
    Curriculum.update {_id: curriculumId}, {$set: {lessons: newLessons}}, (err)->
      if err
        throw new Meteor.Error 'mongo-error', err
        console.log "Error updating curriculum:", err

  # Takes in a module id and a lesson id. The module is removed from the Modules collection
  # and the Lessons collection is updated. If an error occurs in updating the lesson or removing 
  # the module, an error is thrown.
  deleteModule: (moduleId, lessonId, deleteFromModule)->
    check moduleId, String
    check lessonId, String
    lesson = Lessons.findOne {_id: lessonId}
   
    if deleteFromModule.length > 0
      Meteor.call "deleteModuleFromS3", moduleId, deleteFromModule
    
    modules = lesson.modules
    newModules = (module for module in modules when module != moduleId)
    
    Lessons.update {_id: lessonId}, {$set:{modules: newModules}}, (err)->
      if err
        throw new Meteor.Error "mongo-error", err
        console.log "Error updating lesson:", err
        
    Modules.remove {_id: moduleId}, (err)->
      console.log "removing module"
      if err
        throw new Meteor.err "mongo-Error", err
        console.log "Error removing module:", err

  # Takes in a lesson object and removes all of its modules. If an error occurs in finding the lesson 
  # or its modules or during removing, an error is thrown.
  removeAllModules: (lesson, deleteFromModule)->
    if !lesson or !lesson.modules
      throw new Meteor.Error "document-not-found", "Error removing modules"
    
    for module in lesson.modules
      Meteor.call "deleteModule", module, lesson._id, deleteFromModule

  # Takes in a lesson id and module id and appends the module to the lesson by updating. If an error
  # occurs in updating, an error is thrown.
  appendModule: (lessonId, moduleId, order)->
    check lessonId, String
    check moduleId, String
    Lessons.update {_id: lessonId}, {$push: {"modules": {$each: [moduleId], $position: order}}}, (err)->
      if err
        throw new Meteor.Error 'mongo-error', err
        console.log "Error updating lesson:", err

  # Takes in a curriculum id and lesson id and appends the lesson to the curriculum by updating. If
  # an error occurs in updating, an error is thrown.
  appendLesson: (curriculumId, lessonId, order)->
    check curriculumId, String
    check lessonId, String
    curriculum = Curriculum.findOne {_id: curriculumId}
    numLessons = curriculum.lessons.length
    Curriculum.update {_id: curriculumId}, {$push: {"lessons": {$each: [lessonId], $position: order}}}, (err)->
      if err
        throw new Meteor.Error 'mongo-error', err
        console.log "Error updating curriculum:", err
  
  # ?
  getBucket: ()->
    if process.env.METEOR_ENV == 'production'
      return BUCKET
    else
      return DEV_BUCKET

  # ?
  contentEndpoint: ()->
    if process.env.METEOR_ENV == 'production'
      return "https://noorahealthcontent.s3-us-west-1.amazonaws.com/"
    else
      return 'https://noorahealth-development.s3-us-west-1.amazonaws.com/'

}
