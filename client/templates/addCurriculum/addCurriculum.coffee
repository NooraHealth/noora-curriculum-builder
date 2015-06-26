


Template.curriculumBuilder.events {
  "click .delete-lesson": (event, template)->
    event.preventDefault()
    lessonID = $(event.target).closest("table").attr "id"
    Meteor.call "deleteLesson", lessonID

  "click .delete-module": (event, template)->
    event.preventDefault()
    moduleId = $(event.target).closest("tr").attr "id"
    parentId = $(event.target).closest("table").attr "id"
    Meteor.call "deleteModule", moduleId, parentId, (err)->
      if err
        Session.set "error-message", "There was an error deleting the module: " +err
    
  "click button[name=upload]":(event, template) ->
    event.preventDefault()
    inputs =  $("input.file")

    #for input in inputs
      #file = input.files[0]
      #console.log "Here are the files to input"
      #if file?
        #uploader = new Slingshot.Upload "s3"
        #id = Uploaders.insert uploader
        #uploader.send file , (err, downloadURL) ->
          #if err
            #console.log "Error uploading file: ", err
            #console.log file
            #alert "A file failed to load! ", err
          #else
            #console.log "File uploaded: ", downloadURL
            #console.log Uploaders.find().count()
            #Uploaders.remove {_id: id}
            #console.log Uploaders.find().count()
    
  "click #addLesson":(event, template) ->
    $("#addLessonModal").openModal()

  "click #submitLesson": (event, template)->
    title =  $("#lessonTitle").val()
    tags = $("#lessonTags").val().split()
    lessonImage =$("#lessonImage")[0].files[0]
    lessonIcon =$("#lessonIcon")[0].files[0]

    prefix = Meteor.filePrefix lessonImage
    iconPrefix = Meteor.filePrefix lessonIcon
    
    _id = Lessons.insert {
      title: title
      tags: tags
      image: prefix
      icon: iconPrefix
      modules: []
    }
    lesson = Lessons.update {_id: _id}, {$set: {nh_id: _id}}
    
    curr= Meteor.getCurrentCurriculum()
    Meteor.call "appendLesson", curr._id, _id, (err)->
      if err
        Session.set "error-message", "There was an error adding the lesson:", err

    resetForm()

  "click .add-module": (event, template) ->
    id = $(event.target).closest("table").attr 'id'
    $("#moduleLessonId").attr "value", id
    Session.set "current editing lesson", id
    $("#addModuleModal").openModal()

  "change #moduleType": (event, template) ->
    type = $(event.target).val()
    rows = $("#addModuleModal").find("div[name=attributeRow]")
    $.each(rows, (index, row)->
      if $(row).hasClass type
        $(row).slideDown()
      else
        $(row).slideUp()
    )

  "click #submitModule": (event, template)->
    question = $("#moduleQuestion").val()
    title=$("#moduleTitle").val()
    tags = $("#moduleTags").val().split()
    type= $("#moduleType").val()
   
    audio = Meteor.filePrefix $("#moduleAudio")[0].files[0]
    correctAudio = Meteor.filePrefix $("#moduleCorrectAudio")[0].files[0]
    incorrectAudio = Meteor.filePrefix $("#moduleIncorrectAudio")[0].files[0]
    image =  Meteor.filePrefix $("#moduleImage")[0].files[0]
    video =  Meteor.filePrefix $("#moduleVideo")[0].files[0]
    videoUrl = $("#moduleVideoUrl").val()
    correctOptions = []

    options = []
    if !type
      alert "please identify a module type"
      return
    
    if !audio and type != "VIDEO"
      alert "Missing module audio"
      return

    if (!correctAudio or !incorrectAudio) and isQuestion(type)
      alert "You are missing some audio files"
      return

    if !video and !videoUrl and type=="VIDEO"
      alert "You are missing the video file"
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

    if type=="SCENARIO"
      correctOptions = [$("input[name=scenario_answer]:checked").attr "id"]
      options = ["Normal" , "CallDoc", "Call911"]

    if type=="BINARY"
      correctOptions=  [$("input[name=binary_answer]:checked").attr "id"]
      options = ["Yes", "No"]

    if type=="MULTIPLE_CHOICE"
      options = ( Meteor.filePrefix input.files[0] for input in $("input[name=option]") )
      correctOptions = (Meteor.filePrefix input.files[0] for input in $("input[name=option]") when $(input).closest("div").hasClass 'correctly_selected')

    if isQuestion(type) and options.length==0
      alert "You did not specify any options"
      return
    
    if isQuestion(type) and correctOptions.length==0
      alert "You did not select the correct answer(s)"
      return
    lessonId = Session.get "current editing lesson"

    _id = Modules.insert {
      type:type
      parent_lesson: lessonId
      correct_answer: correctOptions
      title:title
      question:question
      tags: tags
      options:options
      video: video
      video_url: videoUrl
      image: image
      audio: audio
      correct_audio: correctAudio
      incorrect_audio: incorrectAudio
    }

    updated = Modules.update {_id: _id}, {$set: {nh_id: _id}}
    Meteor.call "appendModule", lessonId, _id, (err)->
      if err
        Session.set "error-message", "There was an error inserting the module into the database:" +err
    resetForm()

}

Template.addModuleModal.events {
  "click div.uploadOption": (event, template)->
    $(event.target).closest("div").toggleClass "correctly_selected"
    $(event.taddrget).closest("input.file").toggleClass "correct"
}

Template.curriculumBuilder.onRendered ()->
  $("select").material_select()

###
# HELPER FUNCTIONS
###
resetForm = () ->
  addModuleModal = $("#addModuleModal")
  for input in addModuleModal.find("div[name=attributeRow]")
    $(input).slideUp()
  for input in $("input:not(.no-reset)")
    input.value = ""

isQuestion = (type)->
  return type== "BINARY" or type=="SCENARIO" or type=="MULTIPLE_CHOICE"
