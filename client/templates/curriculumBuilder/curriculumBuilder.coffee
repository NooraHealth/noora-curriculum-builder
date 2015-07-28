###
# Event handlers for adding and deleting lessons and modules.
# Templates involved: curriculumBuilder in curriculumBuilder.html
# and addLessonModal and addModuleModal in addModals.html
###

Template.curriculumBuilder.events {
  # Delete lesson
  "click .delete-lesson": (event, template)->
    event.preventDefault()
    lessonId = $(event.target).closest("table").attr "id"
    curriculum = Meteor.getCurrentCurriculum()
    Meteor.call "deleteLesson", curriculum._id, lessonId, lessonFiles, moduleFiles
  
  # Delete module
  "click .delete-module": (event, template)->
    event.preventDefault()
    moduleId = $(event.target).closest("tr").attr "id"
    lessonId = $(event.target).closest("table").attr "id"
    Meteor.call "deleteModule", lessonId, moduleId, moduleFiles, (err)->
      if err
        Session.set "error-message", "There was an error deleting the module:", err
  
  # Add lesson
  "click #addLesson": (event, template) ->
    Meteor.setCurrentLesson "null"
    $("#addLessonModal").openModal()

  # Add module
  "click .add-module": (event, template) ->
    lessonId = $(event.target).closest("table").attr 'id'
    $("#moduleLessonId").attr "value", lessonId
    Meteor.setCurrentLesson lessonId
    Meteor.setCurrentModule "null"
    $("#addModuleModal").openModal()
  
  # Update lesson
  "click #updateLesson": (event, template)->
    lessonId = $(event.target).parent().parent().parent().parent().attr "id"
    Meteor.setCurrentLesson lessonId
    lesson = Lessons.find {_id: lessonId}
    console.log "lesson is"
    console.log lesson.fetch()
    $("#addLessonModal").openModal()

  # Update module
  "click #updateModule": (event, template)->
    lessonId = $(event.target).parent().parent().parent().attr "id"
    moduleId = $(event.target).parent().parent().attr "id" 
    Meteor.setCurrentLesson lessonId
    Meteor.setCurrentModule moduleId
    module = Modules.find {_id: moduleId}
    console.log "module is"
    console.log module.fetch()
    $("#addModuleModal").openModal() 

  # Select module type  
  "change #moduleType": (event, template) ->
    type = $(event.target).val()
    rows = $("#addModuleModal").find("div[name=attributeRow]")
    $.each(rows, (index, row)->
      if $(row).hasClass type
        $(row).slideDown()
      else
        $(row).slideUp()
    )

  # Slingshots uploaded files. Calls submitLesson or submitModule depending
  # on the module.
  "click button[name=upload]":(event, template) ->
    event.preventDefault()
    inputs = $("input[type=file]")
    for input in inputs
      file = input.files[0]
      console.log "Here are the files to input"
      if file?
        uploader = new Slingshot.Upload "s3"
        id = Uploaders.insert uploader
        uploadFile uploader, file, id
    if ($(event.target).attr "id") is "submitLesson"
      submitLesson() 
    else if ($(event.target).attr "id") is "submitModule"
      submitModule()
    Meteor.setCurrentLesson "null"
    Meteor.setCurrentModule "null"
    resetForm()
}

Template.curriculumBuilder.onRendered ()->
  $("select").material_select()

Template.addModuleModal.events {
  "click div.uploadOption": (event, template)->
    $(event.target).closest("div").toggleClass "correctly_selected"
    $(event.target).closest("input.file").toggleClass "correct"
}

###
# HELPER FUNCTIONS
###
uploadFile = (uploader, file, id)->
  uploader.send file, (err, downloadURL)->
    if err
      uploader.send file, uploadCallback()
    else
      console.log "File uploaded: ", downloadURL
      console.log Uploaders.find().count()
      Uploaders.remove {_id: id}
      console.log Uploaders.find().count()

uploadCallback = (err, downloadURL)->
  console.log "retrying upload"
  if err
    console.log "Error uploading file: ", err
    console.log file
    alert "A file failed to load! ", err
  else
    console.log "File uploaded: ", downloadURL
    console.log Uploaders.find().count()
    Uploaders.remove {_id: id}
    console.log Uploaders.find().count()

resetForm = ()->
  addModuleModal = $("#addModuleModal")
  for input in addModuleModal.find("div[name=attributeRow]")
    $(input).slideUp()
  for input in $("input:not(.no-reset)")
    input.value = ""

noOptionsInputted = (options)->
  notOptions = ["Normal", "CallDoc", "Call911", "Yes", "No"]
  counter = 0
  for option in options
    if option != "" and notOptions.indexOf(option) == -1
      counter++
  if counter > 0
    return false
  return true

isQuestion = (type)->
  return type=="BINARY" or type=="SCENARIO" or type=="MULTIPLE_CHOICE"

getOrder = (order, currentOrder, numElements)->
  if order < 0 or order > numElements - 1
    order = currentOrder
    if order == -1
      order = numElements
  return order

updateLessonFileUploads = (oldLesson, deleteFromLesson, params)->
  deleteFromLesson = []
  params.modules = oldLesson.modules
  if params.image == ""
    params.image = oldLesson.image
  else if oldLesson.image?
    deleteFromLesson.push "image"
  if params.icon == ""
    params.icon = oldLesson.icon
  else if oldLesson.icon? 
    deleteFromLesson.push "icon"
  return deleteFromLesson

updateModuleFileUploads = (oldModule, deleteFromModule, params)->
  deleteFromModule = []
  if params.video == ""
    params.video = oldModule.video
  else if oldModule.video? 
    deleteFromModule.push "video"
  if params.image == ""
    params.image  = oldModule.image
  else if oldModule.image? 
    deleteFromModule.push "image"
  if params.audio == ""
    params.audio = oldModule.audio
  else if oldModule.audio? 
    deleteFromModule.push "audio"
  if params.correct_audio == ""
    params.correct_audio = oldModule.correct_audio
  else if oldModule.correct_audio? 
    deleteFromModule.push "correctAudio"
  if params.incorrect_audio == ""
    params.incorrect_audio = oldModule.incorrect_audio
  else if oldModule.incorrect_audio? 
    deleteFromModule.push "incorrectAudio"
  if noOptionsInputted(params.options)
    params.options = oldModule.options
  if params.type == "MULTIPLE_CHOICE"  
    correctOptionsIndex = (input.id for input in $("input[name=option]") when $(input).closest("div").hasClass 'correctly_selected')
    params.correct_answer = (params.options[index] for index in correctOptionsIndex)
  return deleteFromModule

updateModuleFieldsByType = (params)->
  if params.type == "VIDEO" and !params.start
    params.start = 0
  if params.type == "SCENARIO"
    params.correct_answer = [$("input[name=scenario_answer]:checked").attr "id"]
    params.options = ["Normal" , "CallDoc", "Call911"]
  if params.type == "BINARY"
    params.correct_answer =  [$("input[name=binary_answer]:checked").attr "id"]
    params.options = ["Yes", "No"]
  if params.type == "MULTIPLE_CHOICE"
    params.options = (Meteor.filePrefix input.files[0] for input in $("input[name=option]"))
    params.correct_answer = (Meteor.filePrefix input.files[0] for input in $("input[name=option]") when $(input).closest("div").hasClass 'correctly_selected')

submitLesson = ()->
  curriculum = Meteor.getCurrentCurriculum()
  oldLesson = Meteor.getCurrentLesson() # is undefined if creating new lesson
  currentOrder = curriculum.lessons.indexOf("#{oldLesson?._id}")
  order = $("#lessonOrder").val() - 1
  order = getOrder order, currentOrder, curriculum.lessons.length
 
  params = {
    title: $("#lessonTitle").val()
    tags: $("#lessonTags").val().split()
    image: Meteor.filePrefix $("#lessonImage")[0].files[0]
    icon: Meteor.filePrefix $("#lessonIcon")[0].files[0]
    modules: []
  }

  # if creating new lesson
  if !oldLesson 
    console.log params
    # add new lesson to Lessons collection
    lessonId = Lessons.insert params
    Lessons.update {_id: lessonId}, {$set: {nh_id: lessonId}}
    # add lesson to its curriculum
    Meteor.call "addLessonToCurriculum", curriculum._id, lessonId, order, (err)->
      if err
        Session.set "error-message", "There was an error adding the lesson:", err
  
  # if updating lesson
  else
    deleteFromLesson = updateLessonFileUploads oldLesson, deleteFromLesson, params
    # update file uploads
    Meteor.call "deleteLessonFromS3", oldLesson, deleteFromLesson, (err)->
      if err
        Session.set "error-message", "There was an error updating the lesson:", err
    # update order if necessary 
    if order != currentOrder
      Meteor.call "deleteLessonFromCurriculum", curriculum._id, oldLesson._id, (err)->
        if err
          Session.set "error-message", "There was an error updating the lesson:", err
      Meteor.call "addLessonToCurriculum", curriculum._id, oldLesson._id, order, (err)->
        if err
          Session.set "error-message", "There was an error updating the lesson:", err
    # update fields  
    Lessons.update {_id: oldLesson._id}, {$set: params}
  

submitModule = ()->
  lesson = Meteor.getCurrentLesson()
  oldModule = Meteor.getCurrentModule() # is undefined if creating a new module
  currentOrder = lesson.modules.indexOf("#{oldModule?._id}")
  order = $("#moduleOrder").val() - 1
  order = getOrder order, currentOrder, lesson.modules.length
  
  params = { 
    parent_lesson: lesson._id
    question: $("#moduleQuestion").val()
    title: $("#moduleTitle").val()
    tags: $("#moduleTags").val().split()
    type: $("#moduleType").val()
    audio: Meteor.filePrefix $("#moduleAudio")[0].files[0]
    correct_audio: Meteor.filePrefix $("#moduleCorrectAudio")[0].files[0]
    incorrect_audio: Meteor.filePrefix $("#moduleIncorrectAudio")[0].files[0]
    image:  Meteor.filePrefix $("#moduleImage")[0].files[0]
    video:  Meteor.filePrefix $("#moduleVideo")[0].files[0]
    videoUrl: $("#moduleVideoUrl").val()
    start: $("#moduleStartTime").val()
    end: $("#moduleEndTime").val()
    options: []
    correct_answer: []
  }

  updateModuleFieldsByType params

  # if creating new module
  if !oldModule
    moduleErrorChecking params
    # add module to Modules collection
    moduleId = Modules.insert params
    Modules.update {_id: moduleId}, {$set: {nh_id: moduleId}}
    # add module to its lesson 
    Meteor.call "addModuleToLesson", lesson._id, moduleId, order, (err)->
      if err
        Session.set "error-message", "There was an error adding the module:", err

  # if updating this module  
  else
    deleteFromModule = updateModuleFileUploads oldModule, deleteFromModule, params
    moduleErrorChecking params
    # update file uploads
    Meteor.call "deleteModuleFromS3", oldModule, deleteFromModule, (err)->
      if err
        Session.set "error-message", "There was an error updating the module:", err
    # update order if necessary 
    if order != currentOrder
      Meteor.call "deleteModuleFromLesson", lesson._id, oldModule._id, (err)->
        if err
          Session.set "error-message", "There was an error updating the module:", err
      Meteor.call "addModuleToLesson", lesson._id, oldModule._id, order, (err)->
        if err
          Session.set "error-message", "There was an error updating the module:", err
    # update fields  
    Modules.update {_id: oldModule._id}, {$set: params}

moduleErrorChecking = (params)->
  if !params.type
    alert "Please identify a module type"
    return

  if !params.audio  and params.type != "VIDEO" 
    alert "Missing module audio"
    return

  if !params.correct_audio and isQuestion(params.type)
    alert "Missing correct audio"
    return

  if !params.incorrect_audio and isQuestion(params.type)
    alert "Missing incorrect audio"
    return

  if !params.video and !params.videoUrl and params.type=="VIDEO"
    alert "Missing the video file"
    return

  if !params.end and params.type=="VIDEO"
    alert "Missing the end time for the video"
    return

  if !params.image and params.type!="VIDEO" and params.type!="MULTIPLE_CHOICE"
    alert "Missing image file"
    return

  if !params.title and (params.type=="VIDEO" or params.type=="SLIDE")
    alert "Missing title"
    return

  if !params.question and isQuestion(params.type)
    alert "Missing question"
    return

  if isQuestion(params.type) and params.options.length==0
    alert "Please specify any options"
    return

  if isQuestion(params.type) and params.correct_answer.length==0
    alert "Please select the correct answer(s)"
    return


