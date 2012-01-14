// The following attempts to define the interface for the dependencies required
// to run the script compiled from the htmlgraph.pde. It mainly exists to get
// the script to run without fatal errors.

// function for retrieving get variables?
var param = function () {
    return "";
};

// looks like a processing function, but it is not defined for some reason
var framerate = function () {

};

// traer physics library - http://murderandcreate.com/physics/
var ParticleSystem = function () {

};

ParticleSystem.prototype.clear = function () {};
ParticleSystem.prototype.tick = function () {};
ParticleSystem.prototype.numberOfParticles = function () {};
ParticleSystem.prototype.numberOfSprings = function () {};

var Smoother3D = function () {

};

Smoother3D.prototype.tick = function () {};
Smoother3D.prototype.x = function () {};
Smoother3D.prototype.y = function () {};
Smoother3D.prototype.z = function () {};

// htmlparser library - Probably should be replaced with a JS DOM parser
var org = {
    htmlparser: {
        Parser: function () {
            this.setURL = function () {};
            this.parse = function () {
                return {
                    elementAt: function () {}
                };
            };
        }
    }
};

var OrFilter = function () {};

OrFilter.prototype.setPredicates = function () {};

var TagNameFilter = function () {};
