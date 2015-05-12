Meteor.startup ()->

  Slingshot.createDirective "s3",Slingshot.S3Storage, {
    bucket: getBucket()
    acl: "public-read",
    AWSAccessKeyId: process.env.AWS_ACCESS_KEY_ID
    AWSSecretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    region: REGION,
    authorize: () ->
      #Deny uploads if user is not logged in.
      if not Meteor.user()?
        message = "Please login before posting files"
        throw new Meteor.Error("Login Required", message)

      return true

    key:(file) ->
      return Meteor.filePrefix(file)

  }

getBucket = ()->
  console.log "getting bucket: ", process.env
  if process.env.NODE_ENV == 'production'
    return BUCKET
  else
    return DEV_BUCKET
