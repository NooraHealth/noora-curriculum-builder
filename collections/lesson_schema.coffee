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
  imgSrc: ()->
    return getMediaUrl()+ @.image

  getSublessonDocuments: ()->
    if !this.has_sublessons
      return []

    lessonDocuments = []
    _.each this.lessons, (lessonID) ->
      lesson = Lessons.findOne {nh_id: lessonID}
      if lesson?
        lessonDocuments.push lesson

    return lessonDocuments

  getModulesSequence: ()->
    if !this.first_module
      Meteor.Error "This lesson does not have any modules"
    if this.modules
      moduleDocs = (Modules.findOne {_id: moduleId} for moduleId in @.modules)
      return moduleDocs

    else
      modules = []
      module = @.getFirstModule()
      modules.push module
      until module.isLastModule()
        module = module.nextModule()
        modules.push module
      return modules

  getFirstModule: ()->
    return Modules.findOne {nh_id: @.first_module}

  hasSublessons: ()->
    if @.has_sublessons
      return @.has_sublessons == 'true'
    else
      return false


}

