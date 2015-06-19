
Template.submitCurriculum.helpers {
  progress: ()->
    return this.progress()*100

  uploadersFilter: ()->
    return filterStillLoading this.uploaders

  allLoaded: ()->
    return filterStillLoading(this.uploaders).length == 0

}


filterStillLoading = (uploaders) ->
  stillLoading = []
  uploaders.forEach (l)->
    if l.progress() < 1
      stillLoading.push l
  return stillLoading


Template.submitCurriculum.events {
  "click #submitCurriculum": (event, template) ->
    title = $("#curriculumTitle").val()
    condition = $("#condition").val()

    if !title
      alert "Please identify a title for your curriculum"
      return

    currentCurriculum = Meteor.getCurrentCurriculum()
    curriculumWithThisTitle = Curriculum.findOne {title: title}
    if curriculumWithThisTitle and curriculumWithThisTitle._id !=currentCurriculum._id
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
      }
      Meteor.call "updateCurriculum",currentCurriculum._id, data, (err)->
        if err
          Session.set "error-message", err
          return

      alert("New curriculum created")
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
