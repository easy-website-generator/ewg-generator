Generator = require '../index'
expect  = require('chai').expect
spy     = require('sinon').spy

describe 'ewg/generator', ->
  generator  = new Generator('test', './test/fixtures/test.yml')
  minimal    = new Generator('test', './test/fixtures/test.minimal.yml')
  repetitive = new Generator('test', './test/fixtures/test.repetitive.yml')

  describe '#stopOnError()', ->
    it 'returns true unless config.stop_on_error is set', ->
      expect( minimal.stopOnError() ).to.be.true

    it 'returns false if config.stop_on_error is set to false', ->
      expect( generator.stopOnError() ).to.be.false

  describe '#taskName()', ->
    it 'builds the correct task name', ->
      expect( generator.taskName('mytask') ).to.equal('test:mytask')

  describe '#reGenerationTaskName()', ->
    it 'returns generate unless config.regeneration_task_name is set', ->
      expect( minimal.reGenerationTaskName() ).to.equal('generate')

    it 'returns config value if config.regeneration_task_name is set', ->
      expect( generator.reGenerationTaskName() ).to.equal('false')

  describe 'repetitive feature', ->
    describe '#isRepetitive()', ->
      it 'is true with config repetitive part', ->
        expect( repetitive.isRepetitive() ).to.be.true

      it 'is false without config repetitive part', ->
        expect( minimal.isRepetitive() ).to.be.false

    describe '#repetitive()', ->
      it 'merges the main and the repetetive config correct', ->
        i = 1
        repetitive.repetitive (config, index) ->
          expect( config.enabled ).to.be.true
          expect( i ).to.equal(index)
          expect( config.repetitive_test_value ).to.equal(i)
          i++

        # two repetitive sections, but i gets one more increment
        expect( i ).to.equal( 3 )

      it 'calls the callback one time if no repetitive was set', ->
        i = 1
        minimal.repetitive (config) ->
          expect( config.enabled ).to.be.true
          i++

        # two repetitive sections, but i gets one more increment
        expect( i ).to.equal( 2 )
