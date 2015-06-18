Meteor.methods {
  getStubCurriculum: ()->
    curriculumObject = Curriculum.upsert {title: "stub"}, {$set: {title: "stub", lessons: [], condition: "stub" }}
    console.log curriculumObject
    return curriculumObject.insertedId

  appendLesson: (lesson, curriculumId)->
    Curriculum.update {_id: curriculumId}, {$push: {"lessons":lesson}}

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
