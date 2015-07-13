###
# Template helpers for submitCurriculum
# found in submitCurriculum.html
###

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


