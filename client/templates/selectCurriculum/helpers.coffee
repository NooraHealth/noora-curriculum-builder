###
# Template helpers for selectCurriculum template
# found in selectCurriculum.html
###

Template.selectCurriculum.helpers {
  getId: ()->
      return this._id

  curriculums: ()->
      if !Curriculum.findOne {title: TITLE_OF_STUB}
          Curriculum.insert {title: TITLE_OF_STUB, lessons: [], condition: TITLE_OF_STUB}
      return Curriculum.find({})
}
