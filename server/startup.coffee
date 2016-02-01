Meteor.startup ()->
  bucket = Meteor.call "getBucket"
  console.log "ID", process.env.AWS_ACCESS_KEY_ID
  console.log "KEY", process.env.AWS_SECRET_ACCESS_KEY
  console.log bucket
  console.log REGION

  Slingshot.createDirective "s3", Slingshot.S3Storage, {
    bucket: bucket,
    acl: "public-read",
    AWSAccessKeyId: process.env.AWS_ACCESS_KEY_ID,
    AWSSecretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    region: REGION,
    authorize: () ->
      #Deny uploads if user is not logged in
      if not Meteor.user()?
        message = "Please login before posting files"
        throw new Meteor.Error("Login Required", message)

      return true

    key:(file) ->
      console.log "Returning the key: ", Meteor.filePrefix(file)
      return Meteor.filePrefix(file)
  }

  AWS.config.update
    region: REGION
    apiVersion: '2006-03-01'
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY

  @s3 = new AWS.S3({ params: {Bucket: bucket} })
