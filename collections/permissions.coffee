Meteor.users.allow {
  update: (id, docs, field, modifier) ->
    console.log "Allowing the update"
    return true
}
