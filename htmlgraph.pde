// http://www.aharef.info/static/htmlgraph/sourcecode.html 2011.12.30

////////////////////////////////////////////////////////////
//
// A word of caution: This code can be optimized - I made it in quite a hurry. 
// A large chunk is from an example from Traer Physics.
//
// Feel free to use / modify this code however you wish. 
// I would be happy if you would make a reference to the www.aharef.info site!
//
// Oh, and yes, don't forget to check out my alter ego art project, www.onethousandpaintings.com
//
////////////////////////////////////////////////////////////

import traer.physics.*;
import traer.animation.*;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.HashMap;
import processing.net.*;
import org.htmlparser.*;
import org.htmlparser.util.*;
import org.htmlparser.filters.*;
import org.htmlparser.nodes.*;

int totalNumberOfNodes = 0;
ArrayList elements = new ArrayList();
ArrayList parents = new ArrayList();
int nodesAdded = 0;
int maxDegree = 0;
HashMap particleNodeLookup = new HashMap();
HashMap particleInfoLookup = new HashMap();
ParticleSystem physics;
Smoother3D centroid;

// MAKE SURE YOU CHANGE THIS! I might change this site in the future.
// Simply point to a site on your own server that gets the html from any other site.
private String urlPath = "";
private String content;

float NODE_SIZE = 30;
float EDGE_LENGTH = 50;
float EDGE_STRENGTH = 0.2;
float SPACER_STRENGTH = 2000;

final String GRAY = "155,155,155";
final String BLUE = "0,0,155";
final String ORANGE = "255,155,51";
final String YELLOW = "255,255,51";
final String RED = "255,0,0";
final String GREEN = "0,155,0";
final String VIOLET = "204,0,255";
final String BLACK = "0,0,0";



void setup() {
  size(750, 750);
  // if you want to run it locally from within processing, comment the two following lines, and define urlPath as http://www.whateveryoursite.com
  String urlFromForm = param("urlFromForm");
  urlPath += urlFromForm;
  smooth();
  framerate(24);
  strokeWeight(2);
  ellipseMode(CENTER);
  physics = new ParticleSystem( 0, 0.25 );
  centroid = new Smoother3D( 0.0, 0.0, 1.0,0.8 );
  initialize();
  this.getDataFromClient();
}

void getDataFromClient() {
  try {
    org.htmlparser.Parser ps = new org.htmlparser.Parser ();
    ps.setURL(urlPath);
    OrFilter orf = new OrFilter();
    NodeFilter[] nfls = new NodeFilter[1];
    nfls[0] = new TagNameFilter("html");
    orf.setPredicates(nfls);
    NodeList nList  = ps.parse(orf);
    Node node = nList.elementAt (0);
    this.parseTree(node);
    EDGE_STRENGTH = (1.0 / maxDegree) * 5;
    if (EDGE_STRENGTH > 0.2) EDGE_STRENGTH = 0.2;
  }
  catch (Exception e) {
     e.printStackTrace();
  }
}

void initialize() {
  physics.clear();
}

void parseTree(Node node) {
  int degree = 0;
  if (node == null) return;
  String nodeText = node.getText();
  if (node instanceof TagNode && !((TagNode)node).isEndTag())  {
      //println(((TagNode)node).getTagName());
      totalNumberOfNodes++;
      elements.add(node);
      parents.add(((TagNode)node).getParent());
   }
  NodeList children = node.getChildren();
  if (children == null) return;
  SimpleNodeIterator iter = children.elements();
  while(iter.hasMoreNodes()) {
    Node child = iter.nextNode();
    if (child instanceof TagNode && !((TagNode)child).isEndTag()) degree++;
    parseTree(child);
  }
  if (degree > maxDegree) maxDegree = degree;
}


Particle addNode(Particle q) {
  Particle p = physics.makeParticle();
  if (q == null) return p;
  addSpacersToNode( p, q );
  makeEdgeBetween( p, q );
  float randomX =  (float)((Math.random() * 0.5) + 0.5);
  if (Math.random() < 0.5) randomX *= -1;
  float randomY = (float)((Math.random() * 0.5) + 0.5);
  if (Math.random() < 0.5) randomY *= -1;
  p.moveTo( q.position().x() +randomX, q.position().y() + randomY, 0 );
  return p;
}


void draw() {
  //uncomment this if you want your network saved as pdfs
  //beginRecord(PDF, "frameimage-####.pdf");
  if (nodesAdded < totalNumberOfNodes) {
    this.addNodesToGraph();
  }
  else {
    if (EDGE_STRENGTH < 0.05) EDGE_STRENGTH += 0.0001;
  }
  physics.tick( 1.0 );
  if (physics.numberOfParticles() > 1) {
    updateCentroid();
  }
  centroid.tick();
  background(255);
  translate(width/2, height/2);
  scale(centroid.z());
  translate( -centroid.x(), -centroid.y() );
  drawNetwork();
  //uncomment this if you want your network saved as pdfs
  //endRecord();
}

void addNodesToGraph() {
  Particle newParticle;
  TagNode tagNodeToAdd = (TagNode)elements.get(nodesAdded);
  Node parentNode = (Node)parents.get(nodesAdded);
  if (parentNode == null) {
    // this is the html element
    newParticle = addNode(null);
  }
  else {
    Particle parentParticle = (Particle)particleNodeLookup.get(parentNode);
    newParticle = addNode(parentParticle);
  }
  particleNodeLookup.put(tagNodeToAdd,newParticle);
  String nodeColor = GRAY;
  if (tagNodeToAdd.getTagName().equalsIgnoreCase("a")) nodeColor = BLUE;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("div")) nodeColor = GREEN;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("html")) nodeColor = BLACK;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("tr")) nodeColor = RED;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("td")) nodeColor = RED;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("table")) nodeColor =  RED;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("br")) nodeColor =  ORANGE;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("p")) nodeColor =  ORANGE;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("blockquote")) nodeColor =  ORANGE;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("img")) nodeColor =  VIOLET;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("form")) nodeColor =  YELLOW;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("input")) nodeColor =  YELLOW;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("textarea")) nodeColor =  YELLOW;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("select")) nodeColor =  YELLOW;
  else if (tagNodeToAdd.getTagName().equalsIgnoreCase("option")) nodeColor =  YELLOW;
  particleInfoLookup.put(newParticle,nodeColor);
  nodesAdded++;
  //println(nodesAdded + " of " + totalNumberOfNodes + " (" + tagNodeToAdd.getTagName() + ")");
}

void drawNetwork() {
  // draw edges
  stroke( 0 );
  beginShape( LINES );
  for ( int i = 0; i < physics.numberOfSprings(); ++i ){
    Spring e = physics.getSpring( i );
    Particle a = e.getOneEnd();
    Particle b = e.getTheOtherEnd();
    vertex( a.position().x(), a.position().y() );
    vertex( b.position().x(), b.position().y() );
  }
  endShape();
  // draw vertices
  noStroke();
  for ( int i = 0; i < physics.numberOfParticles(); ++i ) {
    Particle v = physics.getParticle(i);
    String info = (String)(particleInfoLookup.get(v));
    if (info != null) {
      String[] infos = info.split(",");
      fill(Integer.parseInt(infos[0]),Integer.parseInt(infos[1]),Integer.parseInt(infos[2]));
    }
    else {
      fill(155);
      }
    ellipse( v.position().x(), v.position().y(), NODE_SIZE, NODE_SIZE );
  }

}




void updateCentroid() {
  float
    xMax = Float.NEGATIVE_INFINITY,
    xMin = Float.POSITIVE_INFINITY,
    yMin = Float.POSITIVE_INFINITY,
    yMax = Float.NEGATIVE_INFINITY;

  for (int i = 0; i < physics.numberOfParticles(); ++i) {
    Particle p = physics.getParticle(i);
    xMax = max(xMax, p.position().x());
    xMin = min(xMin, p.position().x());
    yMin = min(yMin, p.position().y());
    yMax = max(yMax, p.position().y());
  }
  float deltaX = xMax-xMin;
  float deltaY = yMax-yMin;
  if ( deltaY > deltaX ) {
    centroid.setTarget(xMin + 0.5*deltaX, yMin + 0.5*deltaY, height/(deltaY+50));
  }
  else {
    centroid.setTarget(xMin + 0.5*deltaX, yMin + 0.5*deltaY, width/(deltaX+50));
  }
}

void addSpacersToNode( Particle p, Particle r ) {
  for ( int i = 0; i < physics.numberOfParticles(); ++i ) {
    Particle q = physics.getParticle(i);
    if (p != q && p != r) {
      physics.makeAttraction(p, q, -SPACER_STRENGTH, 20);
    }
  }
}

void makeEdgeBetween(Particle a, Particle b) {
  physics.makeSpring( a, b, EDGE_STRENGTH, EDGE_STRENGTH, EDGE_LENGTH );
}
