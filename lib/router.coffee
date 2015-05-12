Router.map ()->

  this.route '/', {
    path: '/'
    template: 'curriculumBuilder'
    layoutTemplate:'layout'
    data: ()->
      console.log "in the home data"
  }

