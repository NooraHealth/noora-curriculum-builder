
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
    Router.go "webapp"
}
