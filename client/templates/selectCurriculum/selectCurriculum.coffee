Template.selectCurriculum.helpers {
  getId: ()->
    return this._id

  curriculums: ()->
    console.log "getting curriculums"
    console.log Curriculum.findOne {title: TITLE_OF_STUB}
    if !Curriculum.findOne {title:TITLE_OF_STUB}
      Curriculum.insert {title: TITLE_OF_STUB, lessons: [] ,condition: TITLE_OF_STUB}
    return Curriculum.find({})
}


Template.selectCurriculumFooter.events {
  'click #selectCurriculum':(event, template) ->
    console.log "Getting the curriculum Id"
    curriculumId = $("input[name=curriculum]:checked").val()
    Meteor.setCurrentCurriculum curriculumId
    Router.go "home"
}
