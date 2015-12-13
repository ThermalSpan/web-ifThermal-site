Camera cam;
TreeContainer pot;//or tree
Menu menu;
Selector selector;
Point nearestNeighbor;
ArrayList<Point> pointList, selectedList;
ArrayList<BoundingBox> boxList;
boolean drawCon, drawHelp, drawTreeRelations, drawTreeBoundaries, drawGnoman, useSelector, drawBoxes;

void setup() {
  size(1000,1000);
  background(120);
  ellipseMode(CENTER);
  cam = new Camera();
  pot = new TreeContainer();
  selector = new Selector();
  nearestNeighbor = null;
  menu = new Menu();
  pointList = new ArrayList<Point>();
  selectedList = new ArrayList<Point>();
  boxList = new ArrayList <BoundingBox>();

  drawCon = false;
  drawHelp = false;
  drawGnoman = true;
  drawTreeRelations = false;
  drawTreeBoundaries = false;
  drawBoxes = false;
  
}

void draw() {
  background(c_background);
  
  pushMatrix();
    cam.update();
    if(drawGnoman) GnomanDraw(200);

    if(drawBoxes) {
      for(BoundingBox bb: boxList) {
        bb.draw();
      }
    }
    
    if(drawTreeBoundaries) {
      pot.drawBoundaries();
    }
   
    if(drawTreeRelations) {
      pot.drawRelations();
    }
  
    for(Point p: pointList) {
      p.draw();
    }
  popMatrix();

  if(useSelector) {
    selector.draw();
  }

  /*if (drawHelp) {
    drawHelpMenu();
  } else {
    menu.draw();
  }*/
  menu.draw();

}

void keyPressed() {
  switch(key) {
    case 'c':
    case 'C':
      pointList.clear();
      selectedList.clear();
      boxList.clear();
      pot.clearTree();
      break;
    case 'h':
    case 'H':
      drawHelp = !drawHelp;
      break;
    case 'k':
    case 'K':
      drawTreeRelations = !drawTreeRelations;
      break;
    case 'j':
    case 'J':
      drawTreeBoundaries = !drawTreeBoundaries;
      break;
    case 'l':
    case 'L':
      drawBoxes = !drawBoxes;
      break;
    case 'e':
    case 'E':
      drawGnoman = !drawGnoman;
      break;
    case 'r':
    case 'R':
      addRandom(1);
      break;
    case 't':
    case 'T':
      addRandom(20);
      break;
  } 
}

void checkSelect() {}

void addBox(BoundingBox bb) {
  boxList.add(bb);
}

void setSelected(ArrayList<Point> pointList) {
  for(Point p: selectedList) {
    p.setUnSelected();
  }
  selectedList = pointList;
  for(Point p: selectedList) {
    p.setSelected();
  }
}

void addRandom(int n) {
  for(int i = 0; i < n; i++) {
     Point p = new Point((int)random(width),(int)random(height));
     Point r = cam.transform(p);
     pointList.add(r);
     pot.insert(r);
  }
}

void GnomanDraw(int r) {
  pushStyle();
  stroke(c_gnoman);
  line(-r,0,r,0);
  line(0,-r,0,r);
  popStyle();
}

void mousePressed() {
  if(mouseButton == LEFT && !menu.mousePressed()) { 
    if(useSelector) {
      selector.mousePressed(); 
    } else {
      cam.mousePressed();
    }
  }
  if(mouseButton == RIGHT) { 
    cam.mousePressed();
  }
}

void mouseDragged() {
  if(mouseButton == LEFT) { 
    if(useSelector) {
      selector.mouseDragged();
    } else {
      cam.mouseDragged();
    }
  }
  if(mouseButton == RIGHT) { 
    cam.mouseDragged(); 
  }
}

void mouseReleased() {
  if(mouseButton == LEFT) { 
    if(useSelector) {
      menu.mouseReleased(); 
    } else {
      cam.mouseReleased();
    }
  }
  if(mouseButton == RIGHT) { 
    cam.mouseReleased(); 
  }
}

class BoundingBox {
  float x1, x2, y1, y2;
  color _c;
  public BoundingBox(float _x1, float _x2, float _y1, float _y2)
  {
    x1 = _x1;
    x2 = _x2;
    y1 = _y1;
    y2 = _y2;
  }

  void setColor (color c) {
    _c = c;
  }
  void draw()
  {
    pushStyle();
    stroke(0);
    fill(_c);
    rect(x1, y1, x2 - x1,y2 - y1);
    popStyle();
  }
}

class CirSHandler implements ButtonHandler{
  void Selected() {
    selector.setSelectMode(1);
    useSelector = true;
  }
}

class RectSHandler implements ButtonHandler{
  void Selected() {
    selector.setSelectMode(0);
    useSelector = true;
  }
}
class PanHandler implements ButtonHandler{
  void Selected() {
    cam.setMode(0);
    useSelector = false;
  }
}

class RotHandler implements ButtonHandler{
  void Selected() {
    cam.setMode(1);
    useSelector = false;
  }
}

class PlaceHandler implements ButtonHandler{
  void Selected() {
    selector.setSelectMode(3);
    useSelector = true;
  }
}

interface ButtonHandler {
  void Selected ();
}

class Button {
  int _x;
  int _y;
  int _w;
  int _h;
  int _r;
  boolean _isSel;
  String _label;
  ArrayList<ButtonHandler> _handlerList;

  Button (int x, int y, String label) {
    _x = x;
    _y = y;
    _w = i_buttonWidth;
    _h = i_buttonHeight;
    _r = i_buttonRad;
    _handlerList = new ArrayList<ButtonHandler> ();
    _label = label;
    _isSel = false;
  }
 
  boolean isMouseOver() {
    return mouseX >= _x && mouseX <= _x + _w && mouseY >= _y && mouseY <= _y + _h;
  }
  
  void Select() {
    _isSel = true;
    for(ButtonHandler h: _handlerList) {
      h.Selected();
    }
  }

  void unSelect() {
    _isSel = false;
  }

  void draw () {
      pushStyle();
      stroke(c_buttonStr);
      if(_isSel) {
        fill(c_buttonSel);
      } else {
        fill(c_buttonDef);
      }
      rect(_x, _y, _w, _h, 0, _r, _r, 0);
      if(_isSel) {
        fill(c_WHITE);
      } else {
        fill(c_BLACK);
      }
      textSize(20);
      text(_label, _x + 3, _y + _h - 10);
      popStyle();
  } 

  void addHandler (ButtonHandler h) {
    _handlerList.add(h);
  }
}
class Camera { 
  float _x;
  float _y;
  float _scale;
  float _angle;
  float _oldX;
  float _oldY;
  float _oldAngle;
  float _oldScale;
  
  int   _initMX;
  int   _initMY;

  int _mode;
  
  Camera() {
    _x = 0.0;
    _y = 0.0;
    _scale = 1.0;
    _angle = 4 * PI;
  }

  void setMode(int mode) {
    _mode = mode;
  }
  
  void update() {
    translate(_x + width/2,_y + height/2);
    rotate(_angle);
    scale(_scale); 
  } 
  
  void mousePressed() {
        _initMX = mouseX;
        _initMY = mouseY;
        _oldScale = _scale;
        _oldX = _x;
        _oldY = _y;
        _oldAngle = _angle;
  }
  
  void mouseDragged() {
    float difX = (float)(mouseX - _initMX);
    float difY = (float)(mouseY - _initMY);
       
    if(mouseButton == RIGHT) {
      difX /= (float)(width);
      difY /= (float)(height);
      _scale = f_EPSILON + abs((1 - 4*(difX + difY)) * _oldScale); 
      _x = _oldX * _scale;
      _y = _oldY * _scale; 
    } else {
      switch(_mode) {
        case 0:
          difX *= 1.0/_scale;
          difY *= 1.0/_scale;
          _x = _oldX + difX;
          _y = _oldY + difY;
          break;
        case 1:
          float initAngle = atan((_initMY - height/2)/(f_EPSILON + _initMX - width/2)); 
          float newAngle = atan((mouseY - height/2)/(f_EPSILON + mouseX - width/2)); 
          float delta = newAngle - initAngle;
          _angle = _oldAngle + delta;
          break;
      }
    }
  }
  
  void mouseReleased() {
    
  }

  Point transform(Point p) {
    float px = (1.0/_scale)*((p._x - width/2) - _x);
    float py = (1.0/_scale)*((p._y - height/2) - _y);
    float x = (cos(_angle)*px + sin(_angle)*py);
    float y = (-sin(_angle)*px + cos(_angle)*py);
    return new Point(x,y);
  }
}
class Menu{
  ArrayList<Button> _buttonList;

  Menu(){
    _buttonList = new ArrayList<Button>();
    makeButtons();
  }
  
  void draw(){
    for(Button b: _buttonList) {
      b.draw();
    }
  }
  
  boolean mousePressed(){
    boolean result = false;
    for(Button b: _buttonList) {
      boolean check = b.isMouseOver();
      if(check) {
        result = true;
        for(Button b0: _buttonList) {
          b0.unSelect();
        }
        b.Select();
        break;
      }
    }
    return result;
  }

  void mouseDragged() { 
    selector.stretchSelection(); 
  }
 
  void mouseReleased() { 
    selector.resetSelection(); 
  }

  void makeButtons() {
    int y = 50;
    Button cirS = new Button (0, y, "Circ Sel");
    y += i_buttonHeight + 10;
    _buttonList.add(cirS);
    cirS.addHandler(new CirSHandler());
   
    Button rectS = new Button (0, y, "Rect Sel");
    y += i_buttonHeight + 10;
    _buttonList.add(rectS);
    rectS.addHandler(new RectSHandler());
    
    Button pan = new Button (0, y, "Pan");
    y += i_buttonHeight + 10;
    _buttonList.add(pan);
    pan.addHandler(new PanHandler());
    
    //Button rot = new Button (0, y, "Rotate");
    //y += i_buttonHeight + 10;
    //_buttonList.add(rot);
    //rot.addHandler(new RotHandler());
 
    Button place = new Button (0, y, "Place");
    y += i_buttonHeight + 10;
    _buttonList.add(place);
    place.addHandler(new PlaceHandler());
    place.Select();
  }
}

void drawHelpMenu() {
    float hwidth = 400;
    float hheight = 600;

    pushStyle();
    strokeWeight (i_helpStrokeWidth);
    stroke(c_helpStroke);
    fill(c_helpBackground);
    rect(width/2 - hwidth/2, height/2 - hheight/2, hwidth, hheight, 50, 50, 50, 50);
    textSize(40);
    fill(c_helpText);
    text("Help:", width/2 - 50, height/2 - hheight/2 + 50);
    textSize (30);
    float x = width/2 - 150;
    float y = height/2 - hheight/2 + 100;
    for (int i = 0; i < i_helpStrings; i++) {
      text(s_helpStrings[i], x, y);
      y += 35;
    }
    popStyle();
}


class Point {
  float _r = i_pointRad;
  float _x;
  float _y;
  boolean _isSelected;

  Point(float x0, float y0) {
    _x = x0;
    _y = y0;
    _isSelected = false;
  }

  void draw() {
    pushStyle();
    stroke(c_pointStroke);
    fill((_isSelected) ? c_pointSelect : c_pointDefault);
    ellipse(_x, _y, i_pointRad, i_pointRad);
    popStyle();
  }

  boolean isSelectedPoint(float x, float y) {
    return (x - _x)*(x - _x) + (y - _y) * (y - _y) < _r * _r;
  }

  boolean isSelectedCir(float x, float y, float r) {
    return (x - _x)*(x - _x) + (y - _y)*(y - _y) < r * r;
  }

  boolean isSelectedRect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    int l0 = lineSideTest(x1, y1, x2, y2, _x, _y);
    int l1 = lineSideTest(x2, y2, x3, y3, _x, _y);
    int l2 = lineSideTest(x3, y3, x4, y4, _x, _y);
    int l3 = lineSideTest(x4, y4, x1, y1, _x, _y);
    
    return (l0 == l1) && (l1 == l2) && (l2 == l3);  
  }

  void setSelected() {
    _isSelected = true;
  }

  void setUnSelected() {
    _isSelected = false;
  }

  void toggleSelected() {
    _isSelected = !_isSelected;
  }
}
// Pallete
color c_WHITE = color (255, 255, 255);
color c_BLACK = color (0, 0, 0);
color c_PROCBLUE = color (5,13,22);
color c_LIGHTBLUE = color (0, 215, 255);
color c_YELLOW = color (215, 255, 0);
color c_HILITE = color (70, 255, 50, 180);//selector filling

// Screen Color
color c_background = color (26, 26, 26);
color c_gnoman = c_LIGHTBLUE;

// Buttons
color c_buttonStr = c_BLACK;
color c_buttonDef = c_WHITE;
color c_buttonSel = color (170, 50, 50);
int   i_buttonWidth = 80;
int   i_buttonHeight = 40;
int   i_buttonRad = 7;

// Menu Colors
color c_modeText = c_BLACK;
color c_modeBackground = color (200,200,200,200);

// Help Colors
color c_helpBackground = c_PROCBLUE;
color c_helpStroke = c_BLACK;
color c_helpText = c_WHITE;
int   i_helpStrokeWidth = 2;

// Point
color c_pointStroke = c_BLACK;
color c_pointDefault = c_WHITE;
color c_pointSelect = color (255, 50, 50);
int   i_pointRad = 20;

// Tree stuff
int   i_relationWidth = 2;
int   i_boundaryWidth = 3;

// Help Strings
int i_helpStrings = 7;
String[] s_helpStrings = {
   "h: Toggle Help",
   "e: Toggle Gnoman",
   "k: Toggle Relations",
   "j: Toggle Boundaries",
   "c: Clear Points",
   "r: Add 1 Random",
   "t: Add 20 Random"
};

// Math Stuff
float f_EPSILON = 0.000001;
float f_INFINITY = 999999;
class Selector{
  int _startX,_startY, _endX, _endY;
  float _state;
  float _a, _b, _radius;
  boolean _selecting, _animating, _searching;
  int _select_mode;
  Point point;
  
  Selector(){
    _selecting = false;
    _animating = false;
    _searching = false;
    _a = 0;
    _b = 0;
    _select_mode = 0; //default is rectangular select
    _endX = -1;
    _endY = -1;
  }
  
  void setSelectMode(int mode){ _select_mode = mode; }
  
  void mousePressed(){//triggered on mousePressed()
  _startX = mouseX;
  _startY = mouseY;  
  boxList.clear();
  switch(_select_mode){
   case 0:  _selecting = true; //rectangular selection
            break;  
   case 1:  _selecting = true; //ellipse selection
            break;
   case 2:  _searching = true; //nearest neighbor search
            _state = 0.0;
            _animating = true;
            break;
   case 3:  Point p = cam.transform(new Point(mouseX, mouseY)); //place point
            pointList.add(p);
            pot.insert(p);
  }
  }
 
  void mouseReleased() {
    resetSelection();
  }
   
  void resetSelection(){//triggered on mouseReleased()
    if(_selecting){  //selecting with rect or circle
      ArrayList<Point> solution;
      switch(_select_mode){
        case 0: 
          Point p1 = cam.transform(new Point(_startX, _startY));
          Point p2 = cam.transform(new Point(_endX+_startX, _endY+_startY));
          solution = pot.queryBox(new BoundingBox(min(p1._x, p2._x), max(p1._x, p2._x), min(p1._y, p2._y), max(p1._y, p2._y)));
          setSelected(solution);
          println("size of list: " + solution.size());
          break;
        case 1:
          Point pp1 = cam.transform(new Point(_startX, _startY));
          Point pp2 = cam.transform(new Point(_endX+_startX, _endY+_startY));
          solution = pot.queryCircle(pp1, dist(pp1._x, pp1._y, pp2._x, pp2._y));
          setSelected(solution);
          println("size of list: " + solution.size());
          break;
      }
      _selecting = false;
      _startX = -1;
      _startY = -1;
    }
    else{
      //_tree.neighborQuery(cam.transform(new Point(_a,_b)),
      _searching = false;
    }
    _endX = -1;
    _endY = -1;    
    _a = 0;
    _b = 0;
  }
 
  void mouseDragged() {
    stretchSelection();  
  }

  void stretchSelection(){
    if(_selecting){
      _endX = mouseX-_startX;
      _endY = mouseY-_startY;
    }
  }

  void draw(){
      pushStyle();
      stroke(color(100,100,100));
      fill(c_HILITE);
      if(_selecting){
        switch(_select_mode){
          case 0:  rect(_startX,_startY,_endX,_endY);
                   break;
          case 1:  _a = mouseX-_startX;
                   _b = mouseY-_startY;
                   _radius = sqrt(_a*_a+_b*_b);
                   ellipseMode(RADIUS);
                   ellipse(_startX,_startY,_radius,_radius);
                   line(_startX,_startY,mouseX,mouseY);
                   ellipseMode(CENTER);
                   break;
      }
    }
  if(_animating){ neighborAnimation(); }
  popStyle();
  }
    
  void neighborAnimation(){
    float elapsedTime = constrain(1f/frameRate, 16f/1000f, 32f/1000f);
    _state += max( 8 * elapsedTime *  sin(_state*PI), 0.01);
    float r = _state * 100;
    ellipseMode(RADIUS);
    ellipse(_startX,_startY,r,r);
    if(_state > 1.0) { 
      _animating = false;
      _searching = false;
    }
  }  
}
int lineSideTest (float ax0, float ay0, float ax1, float ay1, float px, float py) {
  float val = (ax1 - ax0) * (py - ay0) - (ay1 * ay0) * (px - ax0);
  if (val == 0) {
    return 0;
  } else if (val > 0) {
    return 1;
  } else {
    return -1;
  }
}

boolean containsBox(BoundingBox a, BoundingBox b)
{//does a contain b?
  return b.x1 >= a.x1 && b.x2 <= a.x2 && b.y1 >= a.y1 && b.y2 <= a.y2; 
}

boolean intersectsBox(BoundingBox a, BoundingBox b)
{
  if(containsBox(a,b) || containsBox(b,a))  return true;
  return ((a.x1 <= b.x2 && a.x1 >= b.x1 && a.y1 <= b.y2 && a.y2 >= b.y1) || (b.x1 <= a.x2 && b.x1 >= a.x1 && b.y1 <= a.y2 && b.y2 >= b.y1));
}

boolean inBox(Point p, BoundingBox a)
{
  return p._x >= a.x1 && p._x <= a.x2 && p._y >= a.y1 && p._y <= a.y2;
}

//random helper function I don't know where to put
ArrayList<Point> merge(ArrayList<Point> a, ArrayList<Point> b) {
  for(Point p : b)
    a.add(p);
  return a;
}
class KdTree {
  KdTree _left, _right, _parent;
  Point _loc;
  float _x1, _x2, _y1, _y2;
  int _depth;
  color _relationC;
  color _boundaryC;
  boolean _dir; // Vertical->True, Horizontal->False
  boolean _parDir; // Left->True, Right->False
  BoundingBox _bb;
  
  public KdTree(KdTree parent, boolean parDir, Point p, boolean vert, int depth, BoundingBox bb) {
    _parent = parent;
    _loc = p;
    _dir = vert;
    _parDir = parDir;
    _depth = depth;
    _bb = bb;
    _boundaryC = colorizeBoundary(depth);
    _relationC = colorizeRelation(depth);
    _left = null;
    _right = null;
    _bb.setColor (colorizeBox(depth));

    calcBoundary();    
  }
  
  
  void insert(Point p) {
    KdTree parent = search(p);
    
    if(parent._dir) {            // If parent is vertical
      if(parent._loc._x > p._x) {
        BoundingBox bb = new BoundingBox(parent._bb.x1, parent._loc._x, parent._bb.y1, parent._bb.y2);
        parent._left = new KdTree(parent, true, p, !parent._dir, parent._depth + 1, bb);
      } else {
        BoundingBox bb = new BoundingBox(parent._loc._x, parent._bb.x2, parent._bb.y1, parent._bb.y2);
        parent._right = new KdTree(parent, false, p, !parent._dir, parent._depth + 1, bb);
      }
    } else {
      if(parent._loc._y > p._y) {
        BoundingBox bb = new BoundingBox(parent._bb.x1, parent._bb.x2, parent._bb.y1, parent._loc._y);
        parent._left = new KdTree(parent, true, p, !parent._dir, parent._depth + 1, bb);
      } else {
        BoundingBox bb = new BoundingBox(parent._bb.x1, parent._bb.x2, parent._loc._y, parent._bb.y2);
        parent._right = new KdTree(parent, false, p, !parent._dir, parent._depth + 1, bb);
      }
    }
  }

  KdTree search(Point p) {
    if(_dir) {                   // If vertical
      if(p._x < _loc._x) {       // If p is to the left of _loc
        if(_left != null) {
          return _left.search (p);
        } else {
          return this;
        }
      } else {                    // Then p is to the right of _loc
        if(_right != null) {
          return _right.search (p);
        } else {
          return this;
        } 
      }
    } else {                      // If Horizontal
      if(p._y < _loc._y) {        // If p is under _loc
        if(_left != null) {
          return _left.search(p);
        } else {
          return this;
        }
      } else {                   // Then p is over _loc
        if(_right != null) {
          return _right.search(p);
        } else {
          return this;
        }
      }
    }
  }

  ArrayList<Point> report() {
    ArrayList<Point> rightRes = new ArrayList<Point>();
    ArrayList<Point> leftRes = new ArrayList<Point>();
    leftRes.add(_loc);

    if(_left != null)
      leftRes = merge(leftRes, _left.report());    
    if(_right != null)
      rightRes = _right.report();

    addBox (_bb);

    return merge(rightRes, leftRes);
  }
  
  ArrayList<Point> queryBox(BoundingBox range) {
    ArrayList<Point> rightRes = new ArrayList<Point>();
    ArrayList<Point> leftRes = new ArrayList<Point>();
    addBox(_bb); 
    if(inBox(_loc, range)) {
      rightRes.add(_loc);   
    }   
    
    if(_left != null) {
      if(containsBox(range, _left._bb)) 
        leftRes = _left.report();

      else if(intersectsBox(_left._bb, range)) 
        leftRes = _left.queryBox(range);
    }
    
    if(_right != null) {
      if(containsBox(range, _right._bb)) 
        rightRes = merge(_right.report(), rightRes);
      
      else if(intersectsBox(_right._bb, range)) 
        rightRes = merge(_right.queryBox(range), rightRes);
    }
    return merge(rightRes, leftRes);
  }
  
  ArrayList<Point> queryCircle(Point c, float r) {
    ArrayList<Point> rightRes = new ArrayList<Point>();
    ArrayList<Point> leftRes = new ArrayList<Point>();
    addBox(_bb); 
    if(inCircle(c, r, _loc)) 
      rightRes.add(_loc);      
    
    if(_left != null) {
      if(circleContainsBox(_left._bb, c._x, c._y, r)) 
        leftRes = _left.report();

      else if(rectCircleIntersect(_left._bb, c, r)) 
        leftRes = _left.queryCircle(c, r);
    }
    
    if(_right != null) {
      if(circleContainsBox(_right._bb, c._x, c._y, r)) 
        rightRes = merge(_right.report(), rightRes);
      
      else if(rectCircleIntersect(_right._bb, c, r)) 
        rightRes = merge(_right.queryCircle(c, r), rightRes);
    }
    return merge(rightRes, leftRes);
  }
  
  void drawRelations() {
    pushStyle();
    strokeWeight(i_relationWidth);
    stroke(_relationC);
    if(_left != null) {
      line(_loc._x, _loc._y, _left._loc._x, _left._loc._y);
      _left.drawRelations();
    }
    if(_right != null) {
      line(_loc._x, _loc._y, _right._loc._x, _right._loc._y);
      _right.drawRelations();
    }
    popStyle();
  }

  void drawBoundaries () {
    pushStyle();
    strokeWeight(i_boundaryWidth);
    stroke(_boundaryC);
    line(_x1, _y1, _x2, _y2);
    popStyle();
    if(_left != null) {
      _left.drawBoundaries();
    }
    if(_right != null) {
      _right.drawBoundaries();
    }
  }
  
  void calcBoundary () {
    if(_parent == null) {     // Has no Parent, infinite in both directions
      if (_dir) {
        _x1 = _loc._x;
        _x2 = _loc._x;
        _y1 = f_INFINITY;
        _y2 = -f_INFINITY;
      } else {
        _x1 = f_INFINITY;
        _x2 = -f_INFINITY;
        _y1 = _loc._y;
        _y2 = _loc._y;
      }
    } else {                 // Has a parent, half line is made
      if (_dir) {
        _x1 = _loc._x;
        _x2 = _loc._x;
        _y1 = _parent._loc._y;
        if (_parDir) {
          _y2 = -f_INFINITY;
        } else {
          _y2 = f_INFINITY;
        }
      } else {
        _x1 = _parent._loc._x;
        _y1 = _loc._y;
        _y2 = _loc._y;
        if(_parDir) {
          _x2 = -f_INFINITY;
        } else {
          _x2 = f_INFINITY;
        }
      }
      
      if (_parent._parent != null && _parent._parent._parent != null) { // is depth at least depth 3, might be bounded in both dir 
        if (_parDir != _parent._parent._parDir) { // Will "curl" into a prev bar
          if(_dir) {
            _y2 = _parent._parent._parent._loc._y;
          } else {
            _x2 = _parent._parent._parent._loc._x;
          }
        } else {  // Who knows? but it will share same bound as par's par
          if(_dir) {
            _y2 = _parent._parent._y2;
          } else {
            _x2 = _parent._parent._x2;
          }
        }
      }
    }
  }

  color colorizeRelation (int depth) {
    float d = depth * 0.2;
    return color((int)255*cos(d) * cos(d), (int)255*abs(sin(d + PI)), (int)255*abs(sin(d+0.5)));
  }

  color colorizeBoundary (int depth) {
    float d = depth * 0.2;
    return color((int)255*abs(sin(d + 0.3)), (int)255*abs(sin(d+3.0)), (int)255*abs(sin(d+0.7))); 
  }

  color colorizeBox (int depth) {
    float d = depth* 0.2;
    int alpha = 0;
    if (depth != 0) {
      alpha = 20;
    }
    return color((int)255*abs(sin(5*d+0.3)), (int)255*abs(cos(3.1*d+2.0)), (int)255*abs(sin(20* d+0.7)), alpha);
  }
}
class TreeContainer {
  KdTree _tree;
  BoundingBox _bb;

  TreeContainer(){ 
    _tree = null;
    _bb = new BoundingBox(-f_INFINITY, f_INFINITY, -f_INFINITY, f_INFINITY);
  }
  
  void insert(Point p){
    if(_tree != null) { 
      _tree.insert(p); 
    } else { 
      _tree = new KdTree (null, true, p, true, 0, _bb);
    }
  }
  
  KdTree getTree(){ return _tree;}
  
  void clearTree(){ _tree = null; }   
  
  ArrayList<Point> queryBox(BoundingBox bb) {
    if(_tree != null) {
      return _tree.queryBox(bb);
    }
    return new ArrayList<Point>();
  }

  ArrayList<Point> queryCircle(Point p, float r) {
    if(_tree != null) {
      return _tree.queryCircle(p, r);
    }
    return new ArrayList<Point>();
  }


  void setTree (KdTree tree) { _tree = tree; }

  void drawRelations() {
    if(_tree != null) {
      _tree.drawRelations();
    }
  }

  void drawBoundaries() {
    if(_tree != null) {
      _tree.drawBoundaries();
    }
  }
}
boolean rectCircleIntersect(BoundingBox bb, Point p, float r){
  if( inBox(p, bb) ){ return true; } //circle center in rect
  //if( circleContainsBox(bb, p._x, p._y, r)){ return true; }
  if(dist(bb.x1,bb.y1, p._x, p._y) <= r || dist(bb.x1,bb.y2, p._x, p._y)<=r || dist(bb.x2,bb.y1, p._x, p._y)<= r || dist(bb.x2,bb.y2, p._x, p._y) <= r){ return true; }
  if(boxContainsCircle(bb, p._x, p._y, r)){ return true; }
  if(lineIntersectsCircle(bb.x1, bb.y1, bb.x1, bb.y2, p._x, p._y, r)){ return true; }//left:bottom->top
  if(lineIntersectsCircle(bb.x1, bb.y2, bb.x2, bb.y2, p._x, p._y, r)){ return true; }//top:left->right
  if(lineIntersectsCircle(bb.x2, bb.y1, bb.x2, bb.y2, p._x, p._y, r)){ return true; }//right:bottom->top
  if(lineIntersectsCircle(bb.x1, bb.y1, bb.x2, bb.y1, p._x, p._y, r)){ return true; }//bottom: left->right
  else{ return false; }
}
boolean inCircle(Point p, float r, Point q)
{
  return dist(p._x, p._y, q._x, q._y) <= r;
}
boolean circleContainsBox(BoundingBox bb, float cx, float cy, float r){//not currently using this for anything but I wrote it up and didn't know 
 if(dist(bb.x1,bb.y1, cx, cy) <= r && dist(bb.x1,bb.y2, cx, cy)<=r && dist(bb.x2,bb.y1, cx, cy)<= r && dist(bb.x2,bb.y2, cx, cy) <= r){ return true; }
 else{ return false;}
}

boolean boxContainsCircle(BoundingBox bb, float cx, float cy, float r){
  float list[] = new float[4];
  list[0] = dist(cx,cy,bb.x1,cy);
  list[1] = dist(cx,cy,bb.x2,cy);
  list[2] = dist(cx,cy,cx,bb.y2);
  list[3] = dist(cx,cy,cx,bb.y1);
  if(min(list) <= r) return true;
  else return false;
}

boolean lineIntersectsCircle(float a1, float a2, float b1, float b2, float c1, float c2, float r){
  float dpTop = (b1-a1)*(c1-a1)+(b2-a2)*(c2-a2);
  float len = sqrt((b1-a1)*(b1-a1)+(b2-a2)*(b2-a2));
  float dpBot = len*len;
  float projScalar = dpTop/dpBot;
  float orthX = projScalar*(b1-a1);
  float orthY = projScalar*(b2-a2);
  if(!onLine(0.0,0.0,b1-a1,b2-a2,orthX,orthY)){//a1-a1=0,b1-b1=0
    return false;
  }
  else{
    if(dist(orthX, orthY, c1-a1, c2-a2) <= r){ 
      return true; 
    }
    else{
      return false; 
    }
  }
}

boolean onLine(float a1,float a2, float b1, float b2, float p1, float p2){//returns true if p is on segment ab
  if( a1==0 && b1==0 ){//vertical line case
    if( a2<=p2 && p2<=b2 ){ 
      return true; 
  }
    else { 
      return false; 
    }
  }
  else{// a2 == b2 horizontal line case
  if( a1<=p1 && p1<=b1 ){ 
    return true; 
  }
    else{ 
      return false; 
    }
  }
}

/* Useful test suite that can be put at the end of RangeApp constructor for testing
boolean t1 = lineIntersectsCircle(2.0, 1.0 , 5.0,  1.0,  3.5,  3,  2);//horizontal case
  //boolean t1 = lineIntersectsCircle(1.0, 2.0 , 1.0,  5.0,  3.5,  3,  2.0);//vertical case
  if(t1){println("True");}
 else{println("false");}

*/

