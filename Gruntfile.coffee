module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    couchapp:
      qbtd:
        db: 'http://localhost:5984/qbtd'
        app: 'server/server.coffee'
    coffee:
      compile:
        files:
          'client/js/app.js': 'client/coffee/{app,views,simplemodels,statistics}*'
        options:
          sourceMap: true

    emblem:
      compile:
        files:
          'client/js/templates.js': 'client/emblem/*'
      options:
        root: 'client/emblem/'
        dependencies:
          jquery: 'client/js/libs/jquery-1.9.1.js'
          ember: 'client/js/libs/ember-1.0.0-rc.3.js'
          emblem: 'client/js/libs/emblem.js'
          handlebars: 'client/js/libs/handlebars-1.0.0-rc.3.js'

    watch:
      script:
        files: ['client/coffee/*', 'server/**/*']
        tasks: 'default'
      style:
        files: '**/*.less'
        tasks: 'default'
      html:
        files: 'client/*.html'
        tasks: 'default'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-emblem'
  grunt.loadNpmTasks 'grunt-couchapp'
  grunt.registerTask 'generateData', 'Generate fake data', require './scripts/generate.coffee'
  grunt.registerTask 'default', ['coffee', 'couchapp', 'emblem']
  grunt.registerTask 'generate', ['generateData', 'default']
