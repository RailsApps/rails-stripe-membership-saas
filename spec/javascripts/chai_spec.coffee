foobar =
  sayHello: ->
    return 'Hello World!'

describe "Foobar", ->
  describe "#sayHello()", ->
    it "should work with assert", ->
      assert.equal foobar.sayHello(), 'Hello World!'

    it "should work with expect", ->
      expect(foobar.sayHello()).to.equal('Hello World!')

    it "should work with should", ->
      foobar.sayHello().should.equal('Hello World!')