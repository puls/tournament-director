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
          'client/js/app.js': 'client/js/*.coffee'
        options:
          sourceMap: true
    macreload:
      normal:
        browser: 'chrome'
        editor: 'sublime'
    watch:
      script:
        files: '**/*.coffee',
        tasks: 'default'
      style:
        files: '**/*.less',
        tasks: 'default'
      html:
        files: 'client/*.html',
        tasks: 'default'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-couchapp'
  grunt.loadNpmTasks 'grunt-macreload'
  grunt.registerTask 'default', ['coffee', 'couchapp']