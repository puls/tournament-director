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
    macreload:
      normal:
        browser: 'chrome'
        editor: 'sublime'
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
  grunt.loadNpmTasks 'grunt-couchapp'
  grunt.loadNpmTasks 'grunt-macreload'
  grunt.registerTask 'generateData', 'Generate fake data', require './scripts/generate.coffee'
  grunt.registerTask 'default', ['coffee', 'couchapp']
  grunt.registerTask 'generate', ['generateData', 'coffee', 'couchapp']
