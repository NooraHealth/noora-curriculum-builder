Meteor.setCurrentCurriculum = (id)->
  Session.set "current curriculum", id

Meteor.getCurrentCurriculum = ()->
  id = Session.get "current curriculum"
  return Curriculum.findOne {_id: id}

Meteor.getStubCurriculum= ()->
    stub = Curriculum.findOne {title:TITLE_OF_STUB}
    if stub
      return stub
    id = Curriculum.insert {title: TITLE_OF_STUB, lessons: [] ,condition: TITLE_OF_STUB}
    return Curriculum.findOne {_id: id}

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

  return prefix + file.name
