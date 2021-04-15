static int numBoids=200;

Vec2 pos[] = new Vec2[numBoids];
Vec2 vel[] = new Vec2[numBoids];
Vec2 acc[] = new Vec2[numBoids];
boolean lock[]=new boolean[numBoids];
boolean die[]=new boolean[numBoids];
Vec3 clr[] = new Vec3[numBoids];


Vec2 rpos = new Vec2(500,500);

int circuleR=40;
Vec2 rVel= new Vec2(0,0);
Vec2 centerR=new Vec2(rpos.x+circuleR/2,rpos.y+circuleR/2);

Vec2 obsR[]=new Vec2[100];


float maxSpeed = 20;
float targetSpeed = 10;
float maxForce = 1;
float radius = 6;

PImage img_bg;
PImage img_shark;
PImage img_obstacle;

void setup(){
  size(900,900);
  img_shark=loadImage("shark.png");
  img_obstacle=loadImage("obstacle.png");
  img_bg = loadImage("bg.jpg");
  surface.setTitle("Escape from the shark");
  frameRate(100);
  //Initial boid positions and velocities
  for (int i = 0; i < numBoids; i++){
    pos[i] = new Vec2(100+random(100),100+random(100));
    vel[i] = new Vec2(random(1),random(1));
    vel[i].normalize();
    vel[i].mul(10);
    clr[i] = new Vec3(0,255,0);
  }

}


void update(float dt){
  if (rpos.y+circuleR> height){
    rpos.y = height-circuleR;
  }
  if (rpos.y < 0){
    rpos.y = 0;
  }
  if (rpos.x+circuleR> width){
    rpos.x = width-circuleR;
  }
  if (rpos.x < 0){
    rpos.x=0;
  }
  
  rVel = new Vec2(0,0);
  if (leftPressed) rVel.add(new Vec2(-20,0));
  if (rightPressed) rVel.add(new Vec2(20,0));
  if (upPressed) rVel.add(new Vec2(0,-20));
  if (downPressed) rVel.add(new Vec2(0,20));
  rpos.add(rVel.times(dt));
  centerR.x=rpos.x+circuleR/2;
  centerR.y=rpos.y+circuleR/2;

  for (int i = 0; i < numBoids; i++){
    acc[i] = new Vec2(0,0);

    // Seperation Force
    Vec2 seperationForce = new Vec2(0, 0);
    int count = 0;
    for (int j = 0; j < numBoids; j++) {
      float dist = pos[i].distanceTo(pos[j]);
      if ((dist > .01) && (dist < 25.0)) {
        Vec2 diff = pos[i].minus(pos[j]);
        diff.normalize();
        diff.mul(1.0/dist);
        seperationForce.add(diff);
        count++;
      }
    }
    if (count > 0) {
      seperationForce.mul(1.0/count);
    }
    if (seperationForce.length() > 0) {
      seperationForce.normalize();
      seperationForce.mul(maxSpeed);
      seperationForce.subtract(vel[i]);
      if (seperationForce.length() > maxForce)
        seperationForce.setToLength(maxForce);
    }
    acc[i] = acc[i].plus(seperationForce.times(1.3));

    // Attraction Force
    Vec2 attractionForce = new Vec2(0, 0);
    Vec2 sum = new Vec2(0, 0);
    count = 0;
    for (int j = 0; j < numBoids; j++) {
      float dist = pos[i].distanceTo(pos[j]);
      if ((dist > .01) && (dist < 50.0)) {
        sum.add(pos[j]);
        count++;
      }
    }
    if (count > 0) {
      sum.mul(1.0/count);
      Vec2 desired = sum.minus(pos[i]);
      desired.normalize();
      desired.mul(maxSpeed);
      attractionForce = desired.minus(vel[i]);
      if (attractionForce.length() > maxForce)
        attractionForce.setToLength(maxForce);
    }
    acc[i] = acc[i].plus(attractionForce);

    // Alignment Force
    Vec2 alignmentForce = new Vec2(0, 0);
    sum = new Vec2(0, 0);
    count = 0;
    for (int j = 0; j < numBoids; j++) {
      float dist = pos[i].distanceTo(pos[j]);
      if ((dist > .01) && (dist < 50.0)) {
        sum.add(vel[j]);
        count++;
      }
    }
    if (count > 0) {
      sum.mul(1.0/count);
      sum.normalize();
      sum.mul(maxSpeed);
      alignmentForce = sum.minus(vel[i]);
      if (alignmentForce.length() > maxForce)
        alignmentForce.setToLength(maxForce);
    }
    acc[i] = acc[i].plus(alignmentForce.times(1.2));

    // Move away from predators
    if((pos[i].distanceTo(centerR)<circuleR*4+radius)&&!die[i]){ 
      clr[i]=new Vec3(255,255,0);
      Vec2 normal = (pos[i].minus(centerR)).normalized();
      Vec2 force = normal.times(maxForce*3);
      acc[i] = force;
    }

    if(pos[i].distanceTo(centerR)<circuleR/2){
      die[i]=true;
    }

    if(pos[i].distanceTo(centerR)<circuleR+radius){
      clr[i]=new Vec3(255,0,0);
    }
    
    if((pos[i].distanceTo(centerR)>circuleR*4+radius)&&(!die[i])){
      clr[i]=new Vec3(0,255,0);
    }

    // Move away from obstacles
    if (w>0) {
      for (int a=0; a<w; a++) {
        if ((pos[i].distanceTo(obsR[a])<obsRec)&&(!die[i])){ 
          Vec2 normal = (pos[i].minus(obsR[a])).normalized();
          Vec2 force = normal.times(maxForce*5);
          acc[i] = force;
        } else if ((pos[i].distanceTo(obsR[a])<obsRec*3)&&(!die[i])){ 
          Vec2 normal = (pos[i].minus(obsR[a])).normalized();
          Vec2 force = normal.times(maxForce*2);
          acc[i] = acc[i].plus(force);
        }
      }
    }

    // Update Position & Velocity
    vel[i] = vel[i].plus(acc[i].times(dt));
    if (vel[i].length() > maxSpeed){
      vel[i] = vel[i].normalized().times(maxSpeed);
    }
    pos[i] = pos[i].plus(vel[i].times(dt));
     
    if (pos[i].x < -radius) pos[i].x = width+radius;
    if (pos[i].y < -radius) pos[i].y = height+radius;
    if (pos[i].x > width+radius) pos[i].x = -radius;
    if (pos[i].y > height+radius) pos[i].y = -radius;
  }
}


boolean leftPressed, rightPressed, upPressed, downPressed, shiftPressed, moving;
void keyPressed(){
  if (keyCode == LEFT) leftPressed = true; moving=true;
  if (keyCode == RIGHT) rightPressed = true; moving=true;
  if (keyCode == UP) upPressed = true; moving=true; 
  if (keyCode == DOWN) downPressed = true; moving=true;
  if (keyCode == SHIFT) shiftPressed = true; moving=true;
}

void keyReleased(){
  if (keyCode == LEFT) leftPressed = false; moving=false;
  if (keyCode == RIGHT) rightPressed = false; moving=false;
  if (keyCode == UP) upPressed = false;  moving=false;
  if (keyCode == DOWN) downPressed = false;  moving=false;
  if (keyCode == SHIFT) shiftPressed = false;  moving=false;
 
  //if (key == 'r'){
  //  reset=true;
  //}
}

Vec2 obstacle[]=new Vec2[1000];

boolean has[]=new boolean[1000];
int w=0;
void mousePressed(){
  //reset=false;
  obstacle[w]=new Vec2(mouseX-obsRec/2,mouseY-obsRec/2);
  obsR[w]=new Vec2(mouseX,mouseY);
  has[w]=true;
  w+=1;
}


int obsRec=30; //set the size of the obstacle

void draw(){
  
  println(frameRate);
  
  background(img_bg);
  
  float dt = 0.1;
  update(dt);
  
  
  noStroke();
  
  for(int a=0;a<100;a++){
    
   if(has[a]==true){ 
   //println("",((obsRec/2)*1.5));
   //fill(100,0,0);
   //circle(obsR[a].x, obsR[a].y,((obsRec/2)*1.4)*2); 
   image(img_obstacle,obstacle[a].x, obstacle[a].y);
   //fill(100);
   //rect(obstacle[a].x, obstacle[a].y, obsRec, obsRec); 
   //if(reset){
   //  fill(255);
   //  rect(obstacle[a].x, obstacle[a].y, 30, 30);
   //}
  }
  
  }
  //fill(100,0,0);
  //println("1:",circuleR);
  //circle(centerR.x, centerR.y,circuleR*4*2); 

  // fill(255);
  //rect(rpos.x, rpos.y, circuleR, circuleR);
  
  image(img_shark,rpos.x, rpos.y);
  
  Vec2 normal=new Vec2(0,0); 
  Vec2 cw=new Vec2(0,0); 
  Vec2 ccw=new Vec2(0,0); 
  Vec2 turn180=new Vec2(0,0);
  Vec2 m=new Vec2(0,0);

  for (int i = 0; i <numBoids; i++){
    if(die[i]==false){
      stroke(100);
      normal=vel[i].normalized();
      turn180.x=normal.x;
      turn180.y=normal.y;
      cw.x=normal.y;
      cw.y=-normal.x;
      ccw.x=-normal.y;
      ccw.y=normal.x;
      m.x=pos[i].plus(cw.times(radius)).x;
      m.y=pos[i].plus(cw.times(radius)).y;
      fill(clr[i].x, clr[i].y, clr[i].z);
      triangle(pos[i].x, pos[i].y,pos[i].plus(cw.times(radius)).x,pos[i].plus(cw.times(radius)).y, m.plus(normal.times(radius*2)).x,m.plus(normal.times(radius*2)).y);  
      m.x=pos[i].plus(ccw.times(radius)).x;
      m.y=pos[i].plus(ccw.times(radius)).y;
      fill(clr[i].x, clr[i].y, clr[i].z);
      triangle(pos[i].x, pos[i].y,pos[i].plus(ccw.times(radius)).x,pos[i].plus(ccw.times(radius)).y, m.plus(normal.times(radius*2)).x,m.plus(normal.times(radius*2)).y);    
      stroke(clr[i].x, clr[i].y, clr[i].z);
      line(pos[i].x, pos[i].y,pos[i].plus(turn180.times(radius*1.5)).x,pos[i].plus(turn180.times(radius*1.5)).y);   
      stroke(100);
      fill(clr[i].x, clr[i].y, clr[i].z);
      circle(pos[i].x, pos[i].y,radius*2); 
    }
  }


}
