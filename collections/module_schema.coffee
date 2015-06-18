###
# Module
#
# A single unit of instructional material, 
# such as a question, a slide, an audio clip, 
# or a video.
###

ModuleSchema = new SimpleSchema
  nh_id:
    type:String
    min:0
    optional:true
  parent_lesson:
    type:String
    optional: true
  tags:
    type:[String]
    minCount:0
    optional:true
  type:
    type:String
  next_module:
    type:String
    optional:true
  title:
    type:String
    optional:true
  image:
    type:String
    optional: true
  video_url:
    type:String
    optional: true
  #QUESTION MODULE
  question:
    type:String
    optional:true
  explanation:
    type:String
    optional:true
  options:
    type:[String]
    optional:true
  correct_answer:
    type:[String]
    optional:true
  incorrect_audio:
    type:String
    optional:true
  correct_audio:
    type:String
    optional:true
  
  #VIDEO MODULE
  video:
    type:String
    optional:true
    #regEx: /^([/]?\w+)+[.]mp4$/

  #SLIDE OR AUDIO MODULE
  audio:
    type:String
    optional:true
    #regEx: /^([/]?\w+)+[.]mp3$/

Modules.attachSchema ModuleSchema

Modules.helpers {
  imgSrc: ()->
    return getMediaUrl()+ @.image

  audioSrc: ()->
    return getMediaUrl() + @.audio

  incorrectAnswerAudio: ()->
    return getMediaUrl() + @.incorrect_audio

  correctAnswerAudio: ()->
    return getMediaUrl() + @.correct_audio
  
  videoSrc: ()->
    return getMediaUrl() + this.video

  isCorrectAnswer: (response)->
    
    return response in @.correct_answer

  getOptionObjects: ()->
    module = @
    newArr = ({option: option, optionImgSrc: getMediaUrl() + option, nh_id: module.nh_id, i: i} for option, i in @.options)
    return newArr

  option: (i)->
    return @.options[i]

  isVideoModule: ()->
    return @.type == "VIDEO"

  isBinaryModule: ()->
    return @.type == "BINARY"

  isMultipleChoiceModule: ()->
    return @.type == "MULTIPLE_CHOICE"

  isSlideModule: ()->
    return @.type == "SLIDE"
  
  isGoalChoiceModule: ()->
    return @.type == "GOAL_CHOICE"

  isScenarioModule: ()->
    return @.type == "SCENARIO"

  isLastModule: ()->
    return @.next_module == '-1' or @.next_module == -1

  nextModule: ()->
    return Modules.findOne {nh_id: @.next_module}
    
}
      
