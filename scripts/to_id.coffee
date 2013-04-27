module.exports = (name) -> name.toLowerCase().replace /[^a-z0-9]+/g,'_'
