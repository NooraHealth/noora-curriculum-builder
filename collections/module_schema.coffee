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
  start:
    type:Number
    min: 0
    optional:true
  end:
    type:Number
    min: 0
    optional:true

  #SLIDE OR AUDIO MODULE
  audio:
    type:String
    optional:true
    #regEx: /^([/]?\w+)+[.]mp3$/

Modules.attachSchema ModuleSchema

Modules.helpers {
  
  # Returns the image source URL for this module.  
  imgSrc: ()->
    return getMediaUrl()+ @.image

  # Returns the audio source URL for this module.
  audioSrc: ()->
    return getMediaUrl() + @.audio
  
  # Returns the audio source URL for the incorrect answer.
  incorrectAnswerAudio: ()->
    return getMediaUrl() + @.incorrect_audio

  # Returns the audio source URL for the correct answer.
  correctAnswerAudio: ()->
    return getMediaUrl() + @.correct_audio
  
  # Returns the video source URL for this module.
  videoSrc: ()->
    return getMediaUrl() + @.video

  # Takes in a response and returns true if response is found in this module's
  # correct_answer array.
  isCorrectAnswer: (response)->
    return response in @.correct_answer

  # Returns an array of all the option objects for this module.
  getOptionObjects: ()->
    module = @
    newArr = ({option: option, optionImgSrc: getMediaUrl() + option, nh_id: module.nh_id, i: i} for option, i in @.options)
    return newArr

  # Takes in i and returns the option at index i.
  option: (i)->
    return @.options[i]

  # Returns true if this module is a video.
  isVideoModule: ()->
    return @.type == "VIDEO"

  # Returns true if this module is a binary.
  isBinaryModule: ()->
    return @.type == "BINARY"

  # Returns true if this module is multiple choice.
  isMultipleChoiceModule: ()->
    return @.type == "MULTIPLE_CHOICE"

  # Returns true if this module is a slide.
  isSlideModule: ()->
    return @.type == "SLIDE"
  
  # Returns true if this module is a goal choice.
  isGoalChoiceModule: ()->
    return @.type == "GOAL_CHOICE"

  # Returns true if this module is a scenario.
  isScenarioModule: ()->
    return @.type == "SCENARIO"

  # Returns true if this module is the last module.
  isLastModule: ()->
    return @.next_module == '-1' or @.next_module == -1

  # Returns the next module following this module. 
  nextModule: ()->
    return Modules.findOne {nh_id: @.next_module}
    
}
      
