Template.nav.helpers
 logo: ()->
   return MEDIA_URL + "VascularContent/Images/NooraLogo.png"

Template.nav.onRendered ()->
  fview = FView.from this
  surface = fview.view or fview.surface
  surface.setProperties {zIndex: 12}
