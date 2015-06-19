
Template.progress.helpers {
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


Template.progress.events {
  "click #submitCurriculum": (event, template) ->
    title = $("#curriculumTitle").val()

    if !title
      alert "Please identify a title for your curriculum"
      return
    condition = $("#condition").val()
    if !condition
      alert "Please identify a condition for your curriculum"
      return

    lessons = $("table")
    lessonIds = ($(lesson).attr "id" for lesson in lessons)

    Meteor.call "contentEndpoint", (err, contentSrc)->
      if err
        Session.set "error-message", err
        return

      _id = Curriculum.insert {
        contentSrc: contentSrc
        title:title
        lessons: lessonIds
        condition: condition
      }

      Curriculum.update {_id: _id}, {$set: {nh_id:_id}}
      #remove the stub editing curriculum
      #to prepare for a fresh build
      Meteor.call "removeStubCurriculum", (err)->
        if err
          Session.set "error-message", err
          return
      alert("New curriculum created")
      Router.go "webapp"
}
