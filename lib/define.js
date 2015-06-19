/** ---------------------- VARIABLES ------------------------ **/
//The necessary collections --It would be great
Curriculum = new Mongo.Collection("nh_home_pages");
Modules = new Mongo.Collection("nh_modules");
Lessons = new Mongo.Collection("nh_lessons");
Attempts = new Mongo.Collection("nh_attempts");
PreviousJson = new Mongo.Collection("nh_json");
Uploaders = new Mongo.Collection(null);
EditingLessons = new Mongo.Collection(null);
EditingModules = new Mongo.Collection(null);

WEBAPP_URL = "http://52.8.13.95";
TITLE_OF_STUB= "Start a New Curriculum";

REGION="us-west-1";
BUCKET = "noorahealthcontent";
DEV_BUCKET = "noorahealth-development";

CONTENT_FOLDER = "NooraHealthContent/";
VIDEO_FOLDER = "Video/";
IMAGE_FOLDER = "Image/";
AUDIO_FOLDER = "Audio/";

Slingshot.fileRestrictions("s3", {
  allowedFileTypes: ["image/png", "image/jpeg", "image/gif", "video/mp4", "audio/mp3", "audio/x-m4a"],
  maxSize: 500 * 1024 * 1024 // 500 MB (use null for unlimited)
});

