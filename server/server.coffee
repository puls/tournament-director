couchapp = require 'couchapp'
path = require 'path'
fs = require 'fs'

module.exports = ddoc =
  _id: '_design/app'
  rewrites: [
    {from: '/', to: 'index.html'}
    {from: '/api', to: '../../'}
    {from: '/api/*', to: '../../*'}
    {from: '/export/livestat/:file', to: '_list/:file/livestat'}
    {from: '/export/qbj', to: '_list/qbj/dump_qbj'}
    {from: '/*', to: 'index.html'}
  ]
  views: require './views'
  lists: require './lists'
  validate_doc_update: (newDoc, oldDoc, userCtx) ->
    throw 'Only admin can delete documents on this database.'  if newDoc._deleted is true and userCtx.roles.indexOf('_admin') is -1

attachmentPath = path.join __dirname, '../client'
couchapp.loadAttachments ddoc, attachmentPath

for filename in fs.readdirSync attachmentPath
  continue if filename[0] is '.'
  extra = if fs.statSync(path.join attachmentPath, filename).isDirectory() then '/*' else ''
  ddoc.rewrites.splice -1, 0, {from: "/#{filename}#{extra}", to: "/#{filename}#{extra}"}
