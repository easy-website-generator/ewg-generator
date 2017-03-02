Generator = require '../index'
gulp      = require 'gulp'
filenames = require 'gulp-filenames'
fs        = require 'fs'
chai      = require 'chai'
should    = chai.should()

fixturesPath = 'test/fixtures'

describe 'ewg/generator', ->
  generator  = new Generator('test', "#{fixturesPath}/test.yml", gulp)
  minimal    = new Generator('test', "#{fixturesPath}/test.minimal.yml", gulp)
  repetitive = new Generator('test', "#{fixturesPath}/test.repetitive.yml", gulp)

  describe '#taskName()', ->
    it 'builds the correct task name', ->
      generator.taskName('mytask').should.equal('test:mytask')

  describe '#reGenerationTaskName()', ->
    it 'returns generate unless config.regeneration_task_name is set', ->
      minimal.reGenerationTaskName().should.equal('generate')

    it 'returns config value if config.regeneration_task_name is set', ->
      generator.reGenerationTaskName().should.equal('false')

  describe 'repetitive feature', ->
    describe '#isRepetitive()', ->
      it 'is true with config repetitive part', ->
        repetitive.isRepetitive().should.be.true

      it 'is false without config repetitive part', ->
        minimal.isRepetitive().should.be.false

    describe '#repetitive()', ->
      it 'merges the main and the repetetive config correct', ->
        i = 1
        repetitive.repetitive (config, index) ->
          config.enabled.should.be.true
          i.should.equal(index)
          config.repetitive_test_value.should.equal(i)
          i++

        # two repetitive sections, but i gets one more increment
        i.should.equal( 3 )

      it 'calls the callback one time if no repetitive was set', ->
        i = 1
        minimal.repetitive (config) ->
          config.enabled.should.be.true
          i++

        # two repetitive sections, but i gets one more increment
        i.should.equal( 2 )

    describe '#src()', ->
      it 'recognizes hidden files', ->
        fs.unlinkSync './test/tmp' if fs.existsSync './test/tmp'
        
        Promise.all([
          new Promise((resolve, reject) ->
            generator.src(["#{fixturesPath}/**/*"])
                 .pipe(
                    filenames('any'))
                 .pipe(
                    generator.dest("./test/tmp"))
                  .on('end', resolve)
          )
        ]).then ->
          files = filenames.get('any')
          files.should.include('.hidden-file')
          files.should.include('test.yml')
