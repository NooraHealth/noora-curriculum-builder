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
    Meteor.call "deleteLesson", lessonId, curriculum._id
  
  # Delete module
  "click .delete-module": (event, template)->
    event.preventDefault()
    moduleId = $(event.target).closest("tr").attr "id"
    lessonId = $(event.target).closest("table").attr "id"
    Meteor.call "deleteModule", moduleId, lessonId, (err)->
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
    $("#addLessonModal").openModal()

  # Update module
  "click #updateModule": (event, template)->
    lessonId = $(event.target).parent().parent().parent().attr "id"
    moduleId = $(event.target).parent().parent().attr "id" 
    Meteor.setCurrentLesson lessonId
    Meteor.setCurrentModule moduleId
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
      submitLesson event 
    else if ($(event.target).attr "id") is "submitModule"
      submitModule event
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

submitLesson = (event)->
  curriculum = Meteor.getCurrentCurriculum()
  oldLesson = Meteor.getCurrentLesson()
  oldModules = []
  
  title = $("#lessonTitle").val()
  order = $("#lessonOrder").val() - 1
  tags = $("#lessonTags").val().split()
  image = Meteor.filePrefix $("#lessonImage")[0].files[0]
  icon = Meteor.filePrefix $("#lessonIcon")[0].files[0]
  
  numLessons = curriculum.lessons.length
  currentOrder = curriculum.lessons.indexOf("#{oldLesson?._id}")
  if order < 0 or order > numLessons - 1
    order = currentOrder
    if order == -1
      order = numLessons
  else if order > currentOrder
    order += 1
  
  # if updating this lesson
  if oldLesson?
    oldModules = oldLesson.modules
    if image == ""
      image = oldLesson.image
    if icon == ""
      icon = oldLesson.icon
    Meteor.call "deleteLesson", oldLesson._id, curriculum._id

  lessonId = Lessons.insert {
    title: title
    tags: tags
    image: image
    icon: icon
    modules: oldModules
  }
  Lessons.update {_id: lessonId}, {$set: {nh_id: lessonId}}
  Meteor.call "appendLesson", curriculum._id, lessonId, order, (err)->
    if err
      Session.set "error-message", "There was an error adding the lesson:", err

submitModule = (event)->
  lesson = Meteor.getCurrentLesson()
  oldModule = Meteor.getCurrentModule()
  correctOptions = []
  options = []
  
  question = $("#moduleQuestion").val()
  title = $("#moduleTitle").val()
  order = $("#moduleOrder").val() - 1
  tags = $("#moduleTags").val().split()
  type = $("#moduleType").val()
  audio = Meteor.filePrefix $("#moduleAudio")[0].files[0]
  correctAudio = Meteor.filePrefix $("#moduleCorrectAudio")[0].files[0]
  incorrectAudio = Meteor.filePrefix $("#moduleIncorrectAudio")[0].files[0]
  image =  Meteor.filePrefix $("#moduleImage")[0].files[0]
  video =  Meteor.filePrefix $("#moduleVideo")[0].files[0]
  videoUrl = $("#moduleVideoUrl").val()
  startTime = $("#moduleStartTime").val()
  endTime = $("#moduleEndTime").val()

  numModules = lesson.modules.length
  currentOrder = lesson.modules.indexOf("#{oldModule?._id}")
  if order < 0 or order > numModules - 1
    order = currentOrder
    if order == -1
      order = numModules
  else if order > currentOrder
    order += 1

  if type=="VIDEO" and !startTime
    startTime = 0
  
  if type=="SCENARIO"
    correctOptions = [$("input[name=scenario_answer]:checked").attr "id"]
    options = ["Normal" , "CallDoc", "Call911"]
  if type=="BINARY"
    correctOptions=  [$("input[name=binary_answer]:checked").attr "id"]
    options = ["Yes", "No"]
  if type=="MULTIPLE_CHOICE"
    options = (Meteor.filePrefix input.files[0] for input in $("input[name=option]"))
    correctOptions = (input.id for input in $("input[name=option]") when $(input).closest("div").hasClass 'correctly_selected')

  # if updating this module  
  if oldModule?
    if video == ""
      video = oldModule.video
    if image == ""
      image  = oldModule.image
    if audio == ""
      audio = oldModule.audio
    if correctAudio == ""
      correctAudio = oldModule.correct_audio
    if incorrectAudio == ""
      incorrectAudio = oldModule.incorrect_audio
    if noOptionsInputted(options)
      options = oldModule.options
    Meteor.call "deleteModule", oldModule._id, lesson._id
    
  if type=="MULTIPLE_CHOICE"  
    correctOptions = (options[index] for index in correctOptions)

  moduleErrorChecking(question, title, type, audio, correctAudio, incorrectAudio, image, video, videoUrl, correctOptions, options, endTime)
  
  moduleId = Modules.insert {
    type: type
    parent_lesson: lesson._id
    correct_answer: correctOptions
    title: title
    question:question
    tags: tags
    options: options
    video: video
    video_url: videoUrl
    start_time: startTime
    end_time: endTime
    image: image
    audio: audio
    correct_audio: correctAudio
    incorrect_audio: incorrectAudio
  }
  Modules.update {_id: moduleId}, {$set: {nh_id: moduleId}}
  Meteor.call "appendModule", lesson._id, moduleId, order, (err)->
    if err
      Session.set "error-message", "There was an error inserting the module into the database:", err

isQuestion = (type)->
  return type=="BINARY" or type=="SCENARIO" or type=="MULTIPLE_CHOICE"

moduleErrorChecking =(question, title, type, audio, correctAudio, incorrectAudio, image, video, videoUrl, correctOptions, options, endTime)->
  if !type
    alert "Please identify a module type"
    return

  if !audio  and type != "VIDEO" 
    alert "Missing module audio"
    return

  if !correctAudio and isQuestion(type)
    alert "Missing correct audio"
    return

  if !incorrectAudio and isQuestion(type)
    alert "Missing incorrect audio"
    return

  if !video and !videoUrl and type=="VIDEO"
    alert "Missing the video file"
    return

  if !endTime and type=="VIDEO"
    alert "Missing the end time for the video"
    return

  if !image and type!="VIDEO" and type!="MULTIPLE_CHOICE"
    alert "Missing image file"
    return

  if !title and (type=="VIDEO" or type=="SLIDE")
    alert "Missing title"
    return

  if !question and isQuestion(type)
    alert "Missing question"
    return

  if isQuestion(type) and options.length==0
    alert "Please specify any options"
    return

  if isQuestion(type) and correctOptions.length==0
    alert "Please select the correct answer(s)"
    return

noOptionsInputted = (options)->
  notOptions = ["Normal", "CallDoc", "Call911", "Yes", "No"]
  counter = 0
  for option in options
    if option != "" and notOptions.indexOf(option) == -1
      counter++
  if counter > 0
    return false
  return true
