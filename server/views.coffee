fs = require 'fs'
path = require 'path'
module.exports = views = {}
viewPath = path.join __dirname, 'qb-mapreduce', 'views'
for filename in fs.readdirSync viewPath
  key = path.basename filename, path.extname filename
  views[key] = require path.join viewPath, filename
