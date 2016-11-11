changed  = require 'gulp-changed'
gulpif   = require 'gulp-if'
extend   = require 'extend'
log      = require 'ewg-logging'
{Config} = require 'ewg-config'
util     = require 'util'

class Generator
  constructor: (@name, configPath, @gulp, @basePath = '.') ->
    @config = new Config(configPath, @reGenerate).config
    @watch  = @gulp.watch

  if:                 gulpif
  log:       (msg) => log.info("#{@name}: ", msg)
  taskName: (name) => "#{@name}:#{name}"
  task: (name, cb) =>
    @gulp.task(@taskName(name), @gulp.series(cb))

  src: (src) =>
    @gulp.src(@prefixPaths(src))

  changed: (src) =>
    changed(@prefixPaths(src))

  dest: (dest) =>
    @gulp.dest(@prefixPaths(dest))


  prefixPaths: (paths) =>
    if(Array.isArray(paths))
      return paths.map (path) => "#{@basePath}/#{path}"

    "#{@basePath}/#{paths}"

  isRepetitive:   => @config.hasOwnProperty 'repetitive'

  repetitive: (cb) =>
    unless @isRepetitive()
      return cb(-1) unless @config.enabled
      return cb(@config, 0)

    for set, index in @config.repetitive
      config = extend(true, {}, @config, set)
      return cb(-1) unless config.enabled
      cb(config, index + 1)


  reGenerationTaskName: => @config.regeneration_task_name || 'generate'
  reGenerate:           =>
    return if @reGenerationTaskName() == 'false'
    @log('config changed, regenerate')
    #TODO inject generate method, because gulp.run is deprecated in version 4
    @gulp.run @reGenerationTaskName()

  generate: (cb) =>
    @task 'generate', (done) =>
      @repetitive (config, index) =>
        if(config == -1)
          return done()


        return cb(config, index)
        .on('error', done)
        .on('end', done)


  # generate single tasks for repetitive configs
  # untested
  generateAll: (cb) =>
    # one overall generate task
    @generate cb

    # for watching we generate numerated tasks of the childs
    @repetitive (config, index) =>
      @task "generate-#{index}", ->
        cb(config)

  watchAll: (getSelector, runBaseTask = 'generate') =>
    # watch for every repetitive and run individual task on change
    childWatchTasks = []
    @repetitive (config, index) =>
      childWatchTasks.push "watch-#{index}"
      @task "watch-#{index}", =>
        runOnWatch = @taskName("#{runBaseTask}-#{index}")
        @watch(getSelector(config), runOnWatch)

    @task "watch", childWatchTasks


module.exports = Generator
