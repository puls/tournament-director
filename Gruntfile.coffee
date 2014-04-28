module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    couchapp:
      qbtd:
        db: require './scripts/database'
        app: 'server/server.coffee'

    coffee:
      compile:
        files:
          'client/js/app.js': 'client/coffee/*'
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
          handlebars: 'bower_components/handlebars/handlebars.js'

    copy:
      main:
        cwd: 'bower_components'
        src: [
          'bootstrap/dist/js/*'
          'ember/ember.*'
          'emblem/dist/*'
          'handlebars/handlebars.runtime.*'
          'jquery/dist/*.js'
          'typeahead.js/dist/typeahead.jquery.*'
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
  grunt.loadNpmTasks 'grunt-emblem'
  grunt.loadNpmTasks 'grunt-couchapp'
  grunt.registerTask 'generateData', 'Generate fake data', require './scripts/generate.coffee'
  grunt.registerTask 'default', ['coffee', 'emblem', 'couchapp']
  grunt.registerTask 'generate', ['generateData', 'default']
