###
# Attempt
# 
# A user's single attempt, failed or successful, 
# on a single module of any type. 
###

AttemptSchema = new SimpleSchema
  user:
    type:String
  responses:
    type:[String]
    minCount:1
    optional:true
  passed:
    type: Boolean
    min:0
  date:
    type:String
  time_to_complete_in_ms:
    optional: true
    type: Number
  nh_id:
    type:String
    min:0

Attempts.attachSchema AttemptSchema
