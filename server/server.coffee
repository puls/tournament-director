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
  validate_doc_update: (newDoc, oldDoc, userCtx, secCtx) ->
    throw {unauthorized: 'Must be logged in'} unless userCtx.name?
    throw {forbidden: 'No access to this database'} unless secCtx.admins.names.indexOf(userCtx.name) > -1 or userCtx.roles.indexOf('_admin') > -1

attachmentPath = path.join __dirname, '../client'
couchapp.loadAttachments ddoc, attachmentPath

for filename in fs.readdirSync attachmentPath
  continue if filename[0] is '.'
  extra = if fs.statSync(path.join attachmentPath, filename).isDirectory() then '/*' else ''
  ddoc.rewrites.splice -1, 0, {from: "/#{filename}#{extra}", to: "/#{filename}#{extra}"}
