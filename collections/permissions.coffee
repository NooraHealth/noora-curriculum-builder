###
# Permissions
#
# Allows users to always be able to update a document.
# Only runs when client tries to write to the database directly.
# Server code, including method calls, are trusted.
###

Meteor.users.allow {
  update: (id, docs, field, modifier) ->
    console.log "Allowing the update"
    return true
}
