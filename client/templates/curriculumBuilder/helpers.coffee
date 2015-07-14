###
# Template helpers for lessonListItem, addModuleModal, curriculumBuilder templates
# found in curriculumBuilder.html, listItems.html, and addModals.html
#
# Assigns values to template expressions used in the templates.
###

Template.lessonListItem.helpers
# Returns the return value of getModulesSequence() for lesson. 
  modulesInLesson: ()->
    return @.getModulesSequence()

Template.addLessonModal.helpers 
  getTitle: ()->
    lesson = Meteor.getCurrentLesson()
    if !lesson
      return ""
    return lesson.title

  getTags: ()->
    lesson = Meteor.getCurrentLesson()
    if !lesson
        return ""
    return lesson.tags

  getImage: ()->
    lesson = Meteor.getCurrentLesson()
    if !lesson or !lesson.image
      return "No previous upload"
    return lesson.image

  getIcon: ()->
    lesson = Meteor.getCurrentLesson()
    if !lesson or !lesson.icon
      return "No previous upload"
    return lesson.icon

Template.addModuleModal.helpers 
  isCorrectlySelected0:()->
    return getSelection(0)
  
  isCorrectlySelected1:()->
    return getSelection(1)

  isCorrectlySelected2:()->
    return getSelection(2)
  
  isCorrectlySelected3:()->
    return getSelection(3)
  
  isCorrectlySelected4:()->
    return getSelection(4)
  
  isCorrectlySelected5:()->
    return getSelection(5)
  
  getPrevOption0: ()->
    return getOption(0)
 
  getPrevOption1: ()->
    return getOption(1)

  getPrevOption2: ()->
    return getOption(2)
 
  getPrevOption3: ()->
    return getOption(3)
 
  getPrevOption4: ()->
    return getOption(4)
 
  getPrevOption5: ()->
    return getOption(5)
 
  option: (index)->
    return {option: index}

  getStartTime: ()->
    module = Meteor.getCurrentModule()
    if !module or !module.start
      return ""
    return module.start
  
  getEndTime: ()->
    module = Meteor.getCurrentModule()
    if !module or !module.end
      return ""
    return module.end

  isNew: ()->
    module = Meteor.getCurrentModule()
    if !module
      return "selected"
    return ""
  
  isScenario: ()->
    return selectedType("SCENARIO")

  isMultiple: ()->
    return selectedType("MULTIPLE_CHOICE")

  isBinary: ()->
    return selectedType("BINARY")

  isSlide: ()->
    return selectedType("SLIDE")

  isVideo: ()->
    return selectedType("VIDEO")

  getTags: ()->
    module = Meteor.getCurrentModule()
    if !module
      return ""
    return module.tags

  getTitle: ()->
    module = Meteor.getCurrentModule()
    if !module
      return ""
    return module.title

  getQuestion: ()->
    module = Meteor.getCurrentModule()
    if !module
      return ""
    return module.question

  getAudio: ()->
    module = Meteor.getCurrentModule()
    if !module or !module.audio
      return "No previous upload"
    return module.audio

  getCorrectAudio: ()->
    module = Meteor.getCurrentModule()
    if !module or !module.correct_audio
      return "No previous upload"
    return module.correct_audio

  getIncorrectAudio: ()->
    module = Meteor.getCurrentModule()
    if !module or !module.incorrect_audio
      return "No previous upload"
    return module.incorrect_audio

  getImage: ()->
    module = Meteor.getCurrentModule()
    if !module or !module.image
      return "No previous upload"
    return module.image

  getVideo: ()->
    module = Meteor.getCurrentModule()
    if !module or !module.video
      return "No previous upload"
    return module.video

  getVideoUrl: ()->
    module = Meteor.getCurrentModule()
    if !module 
      return ""
    return module.video_url

Template.curriculumBuilder.helpers
# Returns the current curriculum's title
  curriculumTitle: ()->
    curriculum = Meteor.getCurrentCurriculum()
    if curriculum.title is TITLE_OF_STUB
      return "New Title"
    return curriculum.title

# Returns the current curriculum's condition
  curriculumCondition: ()->
    curriculum = Meteor.getCurrentCurriculum()
    if curriculum.condition is TITLE_OF_STUB
        return "New Condition"
    return curriculum.condition

# Returns an array of the current curriculum's lessons
  lessons: ()->
    curriculum = Meteor.getCurrentCurriculum()
    return curriculum.getLessonDocuments()

# ?
Tracker.autorun ()->
  error = Session.get "error-message"
  Materialize.toast

### 
# Helper functions
###

###
selectedType = (option)->
  module = Meteor.getCurrentModule()
  if !module
    return "false"
  if module.type is option
    return "true"
  return "false"
###

getSelection = (index)->
  module = Meteor.getCurrentModule()
  if !module or ((module.correct_answer).indexOf(module.options[index]) == -1)
    return ""
  else
    return "correctly_selected"

getOption = (index)->
  notOptions = ["Normal", "CallDoc", "Call911", "Yes", "No"]
  module = Meteor.getCurrentModule()
  if !module or !(module.options[index]) or (notOptions.indexOf(module.options[index]) != -1)
    return "No previous upload"
  return module.options[index]

