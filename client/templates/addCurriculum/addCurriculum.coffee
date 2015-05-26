
Template.addModuleModal.helpers {
  option: (index)->
    return {option: index}
}


Template.curriculumBuilder.events {
  "click button[name=upload]":(event, template) ->
    event.preventDefault()

    inputs =  $("input.file")

    for input in inputs
      file = input.files[0]
      if file?
        uploader = new Slingshot.Upload "s3"

        uploader.send file , (err, downloadURL) ->
          if err
            console.log "Error uploading file: ", err
            alert "A file failed to load! ", err
          else
            console.log downloadURL
    
  "click #addLesson":(event, template) ->
    $("#addLessonModal").openModal()

  "click #submitLesson": (event, template)->
    title =  $("#lessonTitle").val()
    tags = $("#lessonTags").val().split()
    lessonImage = $("#lessonImage")[0].files[0]
    
    if !title or !lessonImage
      alert "You are missing either the title or the Lesson's image."
      return

    prefix = Meteor.filePrefix lessonImage
    
    _id = Lessons.insert {
      title: title
      tags: tags
      image: prefix
    }

    lesson = Lessons.update {_id: _id}, {$set: {nh_id: _id}}

    $("#lessonsList").append "<li name='lesson' id='#{_id}'>
      <div class='collapsible-header'>
      #{title}  
      <a style='float:right' class='waves-effect waves-blue right-align btn-flat' name='addModule'><i class='mdi-content-add'></i></a>
      </div>
      <div class='collapsible-body'><ul class='collection' id='moduleList#{_id}'></ul></div></li>"

    $(".collapsible").collapsible {
      accordion:false
      expandable:true
    }

    resetForm()

  "click [name^=addModule]": (event, template) ->
    id = $(event.target).closest("li").attr 'id'
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
    
    if !type
      alert "please identify a module type"
      return
    
    if !audio and type != "VIDEO"
      alert "Missing module audio"
      return

    if (!correctAudio or !incorrectAudio) and isQuestion(type)
      alert "You are missing some audio files"
      return

    if !video and type=="VIDEO"
      alert "You are missing the video file"
      return
    
    if !image and type!="VIDEO" and type!="MULTIPLE_CHOICE" and type!="GOAL_CHOICE"
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

    if type=="MULTIPLE_CHOICE" || type=="GOAL_CHOICE"
      options = ( Meteor.filePrefix input.files[0] for input in $("input[name=option]") )
      correctOptions = (Meteor.filePrefix input.files[0] for input in $("input[name=option]") when $(input).closest("div").hasClass 'correctly_selected')


    if isQuestion() and options.length==0
      alert "You did not specify any options"
      return
    
    if isQuestion() and correctOptions.length==0
      alert "You did not select the correct answer(s)"
      return

    _id = Modules.insert {
      type:type
      correct_answer: correctOptions
      title:title
      question:question
      tags: tags
      options:options
      video: video
      image: image
      audio: audio
      correct_audio: correctAudio
      incorrect_audio: incorrectAudio
    }

    updated = Modules.update {_id: _id}, {$set: {nh_id: _id}}
    console.log Modules.findOne {_id: _id}
    lessonId = Session.get "current editing lesson"
    $("#moduleList"+ Session.get "current editing lesson").append "<li class='collection-item' id='#{_id}' name='moduleof#{lessonId}'>#{title}#{question}</li>"
    resetForm()

  "click #submitCurriculum": (event, template) ->
    title = $("#curriculumTitle").val()

    if !title
      alert "Please identify a title for your curriculum"
      return
    condition = $("#condition").val()
    if !condition
      alert "Please identify a condition for your curriculum"
      return

    lessons = $("li[name=lesson]")
    $.each lessons, (index, lesson)->
      lessonId = $(lesson).attr 'id'
      modules = $("li[name=moduleof"+lessonId)
      moduleIds = ( $(module).attr 'id' for module in modules)
      lessonDoc = Lessons.update {_id: lessonId}, {$set:{modules: moduleIds}}
    
    lessonIds = ($(lesson).attr "id" for lesson in lessons)

    _id = Curriculum.insert {
      title:title
      lessons: lessonIds
      condition: condition
    }

    Curriculum.update {_id: _id}, {$set: {nh_id:_id}}
    alert("New curriculum created")
    Router.go "home"
}

Template.addModuleModal.events {
  "click div.uploadOption": (event, template)->
    console.log "clicked"
    $(event.target).closest("div").toggleClass "correctly_selected"
    $(event.taddrget).closest("input.file").toggleClass "correct"
}

Template.curriculumBuilder.onRendered ()->
  $("select").material_select()

resetForm = () ->

  addModuleModal = $("#addModuleModal")
  for input in addModuleModal.find("div[name=attributeRow]")
    $(input).slideUp()

  #$("#default-select").attr "disabled", true
  #$("#default-select").attr "selected", true

    
  for input in $("input:not(.no-reset)")
    input.value = ""

isQuestion = (type)->
  return type== "BINARY" or type=="SCENARIO" or type=="MULTIPLE_CHOICE" or type=="GOAL_CHOICE"
