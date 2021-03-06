###
# Lesson
#
# A lesson is a collection of modules, and may or 
# may not contain sublessons
###

LessonSchema = new SimpleSchema
  short_title:
    type: String
    optional: true
  title:
    type:String
  description:
    type:String
    optional:true
  icon:
    type: String
    #regEx:  /^([/]?\w+)+[.]png/
    optional:true
  image:
    type: String
    #regEx:  /^([/]?\w+)+[.]png/
    optional:true
  imageUrl:
    type:String
    optional:true
  tags:
    type:[String]
    minCount:0
    optional:true
  has_sublessons:
    type:String
    defaultValue: "false"
  lessons:
    type:[String]
    optional:true
  last_modified:
    type: String
    optional: true
    #custom: ()->
#      if this.field('has_sublessons').value == "true"
        #return "required"
  modules:
    type: [String]
    optional:true
  first_module:
    type:String
    optional:true
#    custom: ()->
      #if this.field('has_sublessons').value == "true"
        #return "required"
  nh_id:
    type:String
    optional: true
    min:0

Lessons.attachSchema LessonSchema

Lessons.helpers {
  
  # Returns the image source URL for this lesson.  
  imgSrc: ()->
    return getMediaUrl()+ @.image

  # Returns an array of the module documents in this lesson.
  getModulesSequence: ()->
    if !@.modules
      return []
      
    moduleDocs = (Modules.findOne {_id: moduleId} for moduleId in @.modules)
    return moduleDocs

}


