Router.map ()->

  this.route '/', {
    path: '/'
    name: 'home'
    template: 'curriculumBuilder'
    layoutTemplate:'layout'
    onBeforeAction: ()->
      if Meteor.loggingIn()
        return
      currentCurriculum = Session.get "current curriculum"
      if !currentCurriculum
        Router.go 'selectCurriculum'
      else
        this.next()
    data: ()->
      console.log "in the home data"
      uploaders = Uploaders.find({})
      return {uploaders: uploaders}
  }

  this.route 'selectCurriculum', {
    path: '/selectCurriculum',
    template: 'selectCurriculum',
    layoutTemplate: 'layout',
  }

  this.route("webapp", {where: 'server'}).get ()->
    this.response.writeHead 302, {
      'Location': WEBAPP_URL
    }
    this.response.end()



