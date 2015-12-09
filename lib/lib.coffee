###
# Client-side manipulation
###

# Takes in a curriculum id and sets the "current curriculum" session value to be the id.
Meteor.setCurrentCurriculum = (curriculumId)->
  Session.set "current curriculum", curriculumId

# Returns the current curriculum.
Meteor.getCurrentCurriculum = ()->
  curriculumId = Session.get "current curriculum"
  return Curriculum.findOne {_id: curriculumId}

# Takes in a lesson id and sets the "current lesson" session value to be the id.
Meteor.setCurrentLesson = (lessonId)->
  Session.set "current lesson", lessonId

# Returns the current lesson.
Meteor.getCurrentLesson = ()->
  lessonId = Session.get "current lesson"
  return Lessons.findOne {_id: lessonId}

# Takes in a meteor id and sets the "current module" session value to be the id.
Meteor.setCurrentModule = (moduleId)->
  Session.set "current module", moduleId

# Returns the current module.
Meteor.getCurrentModule = ()->
  moduleId = Session.get "current module"
  module = Modules.findOne {_id: moduleId}
  return module

# Returns the stub curriculum if it exists. If not, the stub curriculum is created
# and inserted into the Curriculm collection and returned. The stub curriculum is
# the placeholder for a new curriculum to be created.
Meteor.getStubCurriculum = ()->
    stub = Curriculum.findOne {title:TITLE_OF_STUB}
    if stub
      return stub
    return Curriculum.insert {title: TITLE_OF_STUB, lessons: [] ,condition: TITLE_OF_STUB}

# Takes in file and returns the file name with the correct type prefix. If file does
# not exist, an empty string is returned.
Meteor.filePrefix = (file)->
  #Store file into a directory by the user's username.
  if not file?
    return ""
  if file.type.match /// video/ ///
    prefix = CONTENT_FOLDER + VIDEO_FOLDER
  if file.type.match /// audio/ ///
    prefix = CONTENT_FOLDER + AUDIO_FOLDER
  if file.type.match /// image/ ///
    prefix = CONTENT_FOLDER + IMAGE_FOLDER

  filename = (file.name).replace(/\s+/g, '')
  return prefix + filename

