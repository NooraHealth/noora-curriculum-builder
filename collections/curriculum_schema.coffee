###
# Curriculum
#
# A single Noora Health curriculum for a condition.
###

#Curriculum = new Mongo.Collection("nh_home_pages");

CurriculumSchema = new SimpleSchema
  title:
    type:String
  contentSrc:
    type:String
    optional: true
  lessons:
    type:[String]
  condition:
    type:String
    min:0
  nh_id:
    optional:true
    type:String
    min:0

Curriculum.attachSchema CurriculumSchema

Curriculum.helpers {
  getLessonDocuments: ()->
    
    if !this.lessons
      throw new Meteor.error "malformed-document", "Your curriculum object
        does not contain a properly formed lessons field."

    lessons = []
    _.each this.lessons, (lessonID) ->
      lesson = Lessons.findOne {nh_id: lessonID}
      if lesson
        lessons.push lesson

    return lessons
}
