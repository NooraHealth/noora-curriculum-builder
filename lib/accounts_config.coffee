AccountsTemplates.configureRoute 'signIn', {
  name: 'signin',
  path:'/signIn',
  redirect: '/',
  template: 'entry',
}

AccountsTemplates.configure {
  confirmPassword: true,
  enablePasswordChange: true,
  forbidClientAccountCreation: false,
  overrideLoginErrors: false,
  sendVerificationEmail: true,
  lowercaseUsername: false,

  # Appearance
  showAddRemoveServices: false,
  showForgotPasswordLink: true,
  showLabels: true,
  showPlaceholders: true,
  defaultLayout: 'entry',

  # Client-side Validation
  continuousValidation: false,
  negativeFeedback: false,
  negativeValidation: true,
  positiveValidation: true,
  positiveFeedback: true,
  showValidating: true,

  # Privacy Policy and Terms of Use
  privacyUrl: 'privacy',
  termsUrl: 'terms-of-use',

  # Redirects
  homeRoutePath: '/',
  redirectTimeout: 4000,

  # Hooks
  #onLogoutHook: myLogoutFunc,
  onSubmitHook: (error, action, final) ->
    user = Meteor.user()
    if !error
      Router.go "/"

  # Texts
  texts: {

    errors: {
      mustBeLoggedIn: "Please log in",
    },
    button: {
        signUp: "Register Now!"
    },
    socialSignUp: "Register",
    socialIcons: {
        "meteor-developer": "fa fa-rocket"
    },
    inputIcons: {
      isValidating: "fa fa-spin fa-spinner",
      hasSuccess: "fa fa-check",
      hasError: "fa fa-cross"
    },

    title: {
      signIn: "",
      signUp: "",
      forgotPwd: "Recover Your Password"
    },
  }
}

AccountsTemplates.configureRoute 'ensureSignedIn', {
  template: 'entry'
}

Router.plugin "ensureSignedIn"
