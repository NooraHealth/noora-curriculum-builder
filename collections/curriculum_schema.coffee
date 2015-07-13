###
# Curriculum
#
# A single Noora Health curriculum for a condition.
###
  
#Curriculum = new Mongo.Collection("nh_home_pages");

CurriculumSchema = new SimpleSchema
  title:
    type:String
    max: 100
    unique: true
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
  # Returns array of lessons. Throws error if lessons field is malformed.
  getLessonDocuments: ()->
    
    if !this.lessons
      throw new Meteor.error "malformed-document", "Your curriculum object
        does not contain a properly formed lessons field."

    lessons = []
    # Iterates through lessons name array and retrieves the corresponding lesson 
    # document from the Lesson collection. Adds lesson to newly created lessons array. 
    _.each this.lessons, (lessonID) ->
      lesson = Lessons.findOne {nh_id: lessonID}
      if lesson
        lessons.push lesson
    
    return lessons
}
