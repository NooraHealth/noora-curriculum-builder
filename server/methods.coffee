###
# Server-side Method Calls
###

Meteor.methods {
  # Takes in a curriculum id and data object and updates curriculum to match the data. If the update fails, an error is thrown. 
  updateCurriculum: (curriculumId, data)->
    Curriculum.update {_id: curriculumId}, {$set:{title: data.title, lessons:data.lessons, contentSrc: data.contentSrc, condition: data.condition}}, (err)->
      if err
        throw new Meteor.Error "mongo-error", err

  # Removes the stub curriculum.
  removeStubCurriculum:()->
    Curriculum.remove {title: TITLE_OF_STUB}
  
  deleteCurriculum: (curriculumId)->
    curriculum = Curriculum.findOne {_id: curriculumId}
    lessons = curriculum.lessons
    for lessonId in lessons
      Meteor.call "deleteLesson", curriculumId, lessonId, lessonFiles, moduleFiles
    Curriculum.remove {_id: curriculumId}, (err)->
      if err
        throw new Meteor.Error "mongo-error", err
  
  # Takes in a lesson id and deletes all the modules and the lesson. The curriculum is then updated. 
  # If lesson or curriculum documents are not found or if update fails, an error is thrown.
  deleteLesson: (curriculumId, lessonId, deleteFromLesson, deleteFromModule)->
    check curriculumId, String
    check lessonId, String
    lesson = Lessons.findOne {_id: lessonId}
    if !lesson
      throw new Meteor.Error "document-not-found", "Lesson to delete could not be found"
    Meteor.call "deleteLessonFromCurriculum", curriculumId, lessonId
    Meteor.call "removeAllModules", lesson, deleteFromModule
    if deleteFromLesson.length > 0
      Meteor.call "deleteLessonFromS3", lesson, deleteFromLesson
    Lessons.remove {_id: lessonId}, (err)->
      if err
        throw new Meteor.err "mongo-Error", err

  deleteLessonFromS3: (lesson, deleteFromLesson)->
    objects = []
    if lesson.image? and ("image" in deleteFromLesson)
      objects.push {Key: lesson.image}
    if lesson.icon? and ("icon" in deleteFromLesson)
      objects.push {Key: lesson.icon}
    if (objects.length > 0)
      objects = notBeingUsed(lesson, objects)
      console.log "About to delete the objects", objects
      s3.deleteObjects {Delete: {Objects: objects} }, (err, data)->
        if err
          console.log err
        else
          console.log data
    return
  
  # Takes in a lesson object and removes all of its modules. If an error occurs in finding the lesson 
  # or its modules or during removing, an error is thrown.
  removeAllModules: (lesson, deleteFromModule)->
    if !lesson or !lesson.modules
      throw new Meteor.Error "document-not-found", "Error removing modules"
    
    for moduleId in lesson.modules
      Meteor.call "deleteModule", lesson._id, moduleId, deleteFromModule
  
  deleteLessonFromCurriculum: (curriculumId, lessonId)->
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
  deleteModule: (lessonId, moduleId, deleteFromModule)->
    check moduleId, String
    check lessonId, String
    module = Modules.findOne {_id: moduleId}
    Meteor.call "deleteModuleFromLesson", lessonId, moduleId
    if deleteFromModule.length > 0
      Meteor.call "deleteModuleFromS3", module, deleteFromModule
    Modules.remove {_id: moduleId}, (err)->
      if err
        throw new Meteor.err "mongo-Error", err

  deleteModuleFromS3: (module, deleteFromModule)->
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
    if (objects.length > 0)
      objects = notBeingUsed(module, objects)
      if objects.length > 0
        s3.deleteObjects {Delete: {Objects: objects} }, (err, data)->
          if err
            console.log err
          else
            console.log data
    return
  
  deleteModuleFromLesson: (lessonId, moduleId)->
    lesson = Lessons.findOne {_id: lessonId}
    modules = lesson.modules
    newModules = (module for module in modules when module != moduleId)
    Lessons.update {_id: lessonId}, {$set: {modules: newModules}}, (err)->
      if err
        throw new Meteor.Error "mongo-error", err
        console.log "Error updating lesson:", err


  # Takes in a lesson id and module id and appends the module to the lesson by updating. If an error
  # occurs in updating, an error is thrown.
  addModuleToLesson: (lessonId, moduleId, order)->
    check lessonId, String
    check moduleId, String
    Lessons.update {_id: lessonId}, {$push: {"modules": {$each: [moduleId], $position: order}}}, (err)->
      if err
        throw new Meteor.Error 'mongo-error', err
        console.log "Error updating lesson:", err

  # Takes in a curriculum id and lesson id and appends the lesson to the curriculum by updating. If
  # an error occurs in updating, an error is thrown.
  addLessonToCurriculum: (curriculumId, lessonId, order)->
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
    if Meteor.settings.METEOR_ENV == 'production'
      return BUCKET
    else
      return DEV_BUCKET

  # ?
  contentEndpoint: ()->
    if Meteor.settings.METEOR_ENV == 'production'
      return "https://noorahealthcontent.s3-us-west-1.amazonaws.com/"
    else
      return 'https://cbdevelopment.s3-us-west-1.amazonaws.com/'

}

###
# HELPER FUNCTIONS
###

notBeingUsed = (currentObject, filesToDelete)->
  allLessonObjects = Lessons.find()
  allLessonObjects.forEach (lessonObject)->
    for file, index in filesToDelete by -1
      if (lessonObject._id != currentObject._id) and ((lessonObject.image == file.Key) or (lessonObject.icon == file.Key))
        console.log "#{file.Key} is being used by lesson titled #{lessonObject.title}"
        filesToDelete.splice(index, 1)
  
  
  allModuleObjects = Modules.find()
  allModuleObjects.forEach (moduleObject)->
    for file, index in filesToDelete by -1
      if (moduleObject._id != currentObject._id) and ((moduleObject.image == file.Key) or (moduleObject.audio == file.Key) or (moduleObject.incorrect_audio == file.Key) or (moduleObject.correct_audio == file.Key) or (moduleObject.video == file.Key))
        console.log "#{file.Key} is being used by module titled #{moduleObject.title}"
        filesToDelete.splice(index, 1)
  
  console.log "filesToDelete is "
  console.log filesToDelete
  return filesToDelete
