module.exports = (grunt) ->
  libs = [
    'client/js/libs/jquery.js'
    'client/js/libs/handlebars.runtime.js'
    'client/js/libs/ember.js'
    'client/js/libs/bootstrap.js'
    'client/js/libs/typeahead.jquery.js'
    'client/js/libs/jspdf.debug.js'
  ]
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    couchapp:
      qbtd:
        db: require './scripts/database'
        app: 'server/server.coffee'

    coffee:
      compile:
        files:
          'client/js/app.js': [
            'client/coffee/app.coffee'
            'client/coffee/db/couch.coffee'
            'client/coffee/app/*'
          ]
        options:
          sourceMap: true
      pouch:
        files:
          'client/js/app.js': [
            'client/coffee/app.coffee'
            'client/coffee/db/pouch.coffee'
            'client/coffee/app/*'
          ]
        options:
          sourceMap: true

    emblem:
      compile:
        files:
          'client/js/templates.js': 'client/**/*.emblem'
      options:
        root: 'client/emblem/'
        dependencies:
          jquery: 'client/js/libs/jquery.js'
          ember: 'client/js/libs/ember.js'
          emblem: 'client/js/libs/emblem.js'
          handlebars: 'client/js/libs/handlebars.min.js'

    concat:
      libs:
        src: libs
        dest: 'client/js/libs.js'
      pouch:
        src: libs.concat 'client/js/libs/pouchdb-nightly.js'
        dest: 'client/js/libs.js'

    copy:
      main:
        cwd: 'bower_components'
        src: [
          'bootstrap/dist/js/*'
          'ember/ember.*'
          'emblem/dist/*'
          'handlebars/handlebars.*.js'
          'jquery/dist/*.js'
          'typeahead.js/dist/typeahead.jquery.*'
          'pouchdb/dist/*.js'
          'jspdf/dist/*.js'
        ]
        dest: 'client/js/libs/'
        flatten: true
        expand: true

    watch:
      script:
        files: ['client/coffee/*', 'client/emblem/**', 'client/css/*', 'server/**/*']
        tasks: 'default'
      style:
        files: '**/*.less'
        tasks: 'default'
      html:
        files: 'client/*.html'
        tasks: 'default'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-emblem'
  grunt.loadNpmTasks 'grunt-couchapp'
  grunt.registerTask 'generateGamesData', 'Generate fake data', require('./scripts/generate.coffee').generateGames
  grunt.registerTask 'generateData', 'Generate fake data', require('./scripts/generate.coffee').generateEverything
  grunt.registerTask 'default', ['concat:libs', 'coffee:compile', 'emblem', 'couchapp']
  grunt.registerTask 'pouch', ['concat:pouch', 'coffee:pouch', 'emblem', 'couchapp']
  grunt.registerTask 'generate', ['generateData', 'default']
  grunt.registerTask 'generateGames', ['generateGamesData', 'default']
