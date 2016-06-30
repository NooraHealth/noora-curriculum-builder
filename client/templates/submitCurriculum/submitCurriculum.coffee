###
# Event handlers for submiting curriculum.
# Templates involved: submitCurriculum
###

Template.submitCurriculum.events {
  "click #submitCurriculum": (event, template) ->
    title = $("#curriculumTitle").val()
    condition = $("#condition").val()
    now = new Date()

    if !title
      alert "Please identify a title for your curriculum"
      return

    curriculum = Meteor.getCurrentCurriculum()
    curriculumWithSameTitle = Curriculum.findOne {title: title}
    if curriculumWithSameTitle and curriculumWithSameTitle._id != curriculum._id
      alert "That curriculum title is already in use. Please choose another title."
      return
    
    if !condition
      alert "Please identify a condition for your curriculum"
      return

    lessons = $("table")
    lessonIds = ($(lesson).attr "id" for lesson in lessons)

    Meteor.call "contentEndpoint", (err, contentSrc)->
      data = {
        contentSrc: contentSrc
        title:title
        lessons: lessonIds
        condition: condition
        last_updated: now
      }
     
      Meteor.call "updateCurriculum", curriculum._id, data, (err)->
        if err
          Session.set "error-message", err
          return

      alert("Curriculum updated.")
      Router.go "selectCurriculum"
    #Meteor.call "contentEndpoint", (err, contentSrc)->
      #if err
        #Session.set "error-message", err
        #return
        
      #_id = Curriculum.insert {
        #contentSrc: contentSrc
        #title:title
        #lessons: lessonIds
        #condition: condition
      #}

      #Curriculum.update {_id: _id}, {$set: {nh_id:_id}}
      ##remove the stub editing curriculum
      ##to prepare for a fresh build
      #Meteor.call "removeStubCurriculum", (err)->
        #if err
          #Session.set "error-message", err
          #return
      #alert("New curriculum created")
      #Router.go "webapp"
}
