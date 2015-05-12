Router.map ()->

  this.route '/', {
    path: '/'
    template: 'curriculumBuilder'
    data: ()->
      console.log "in the home data"
  }

