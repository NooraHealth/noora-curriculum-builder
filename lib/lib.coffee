Meteor.getStubCurriculum= ()->
    stub = Curriculum.findOne {title:"stub"}
    if stub
      return stub
    id = Curriculum.insert {title: "stub", lessons: [] ,condition: "stub"}
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
