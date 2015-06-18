Meteor.methods {
  appendModule: (lessonId, moduleId)->
    Lessons.update {_id: curriculumId}, {$push: {"modules":moduleId}}
    Lessons.findOne {_id: lessonId}

  appendLesson: ( curriculumId, lessonId)->
    Curriculum.update {_id: curriculumId}, {$push: {"lessons":lessonId}}
    console.log Curriculum.findOne {_id: curriculumId}

  getBucket: ()->
    if process.env.METEOR_ENV == 'production'
      return BUCKET
    else
      return DEV_BUCKET

  contentEndpoint: ()->
    if process.env.METEOR_ENV == 'production'
      return "https://noorahealthcontent.s3-us-west-1.amazonaws.com/"
    else
      return 'https://noorahealth-development.s3-us-west-1.amazonaws.com/'

}
