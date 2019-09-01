/**
 * A fun program that spawns bubbles on the screen and allows the user to
 * pop them.
 *
 * Author: Joseph Sturm
 * Date: 8/31/2019
 */

// imports
import processing.sound.SoundFile;

// constants
final int FRAMERATE = 60;          // the scene's framerate
final int BUBBLE_DIAMETER = 75;   // the diameter of each bubble
final int MAX_BUBBLES = 30;        // the max number of bubbles at any time
final int APPEAR_INTERVAL = 1;     // how often bubbles appear
final int NUM_APPEAR = 5;          // the max number of bubbles that can appear

// globals
ArrayList<Bubble> bubbles = new ArrayList<Bubble>();
ArrayList<Splat> splats = new ArrayList<Splat>();
float noise_offset = 0.0;
SoundFile pop;

// class to represent the bubbles
class Bubble {
  
  // possible colors
  final int[] bubble_colors = {
    #4287f5,   // blue
    #d442f5,   // purple
    #42f5ad,   // green
    #f57242,   // orange
    #eff542    // yellow
  };
  
  // the bubble's unique offset in the noise field
  final float diff_factor = random(100);
  
  // the bubble's position on screen
  float pos_x, pos_y;
  
  // the bubble's color
  int color_choice;
  
  // indicates if mouse is over the bubble
  boolean moused_over = false;
  
  Bubble() {
    pos_x = random(width);
    pos_y = random(height);
    
    // pick a random color for the bubble
    color_choice = (int)random(0, bubble_colors.length);
    color_choice = bubble_colors[color_choice];
    
    drawBubble(0);
  }
  
  // update the bubble's location and render it on the screen
  void drawBubble(float noise_offset) {
    
    // get a unique noise value for each bubble by adding its diff factor
    noise_offset += diff_factor;
    
    // update position
    pos_x += 2 * (noise(noise_offset) * 2 - 1);
    pos_y += 2 * (noise(noise_offset + 10) * 2 - 1);
    
    // draw upper left reflection (depth)
    noStroke(); fill(100, 175);
    ellipse(pos_x - BUBBLE_DIAMETER * 0.30, pos_y - BUBBLE_DIAMETER * 0.32, 15, 15);
    
    // draw colored inner ring
    stroke(color_choice, 125); strokeWeight(6); fill(75, 55);
    ellipse(pos_x, pos_y, BUBBLE_DIAMETER - 4, BUBBLE_DIAMETER - 4);
    
    // draw white outer ring
    stroke(230, 150); strokeWeight(2); noFill();
    ellipse(pos_x, pos_y, BUBBLE_DIAMETER, BUBBLE_DIAMETER);
    
    // draw upper left reflection
    noStroke(); fill(255);
    ellipse(pos_x - BUBBLE_DIAMETER * 0.30, pos_y - BUBBLE_DIAMETER * 0.32, 10, 10);
  }
}

// class to represent the splats
class Splat {
  
  // position and alpha (transparency value) for each bubble
  float pos_x, pos_y, alpha;
  
  Splat(float pos_x, float pos_y) {
    this.pos_x = pos_x;
    this.pos_y = pos_y;
    this.alpha = 150;
    
    drawSplat();
  }
  
  // render a splat on the screen
  void drawSplat() {
    noStroke(); fill(255, alpha);
    for (int i = 0; i < 5; i++) {
      ellipse(
        pos_x + random(-45, 45),
        pos_y + random(-45, 45),
        30 + random(-5, 5),
        30 + random(-5, 5)
      );
    }
  }
}

void setup() {
  fullScreen();
  background(0);
  frameRate(FRAMERATE);
  
  // loading the "pop" sound
  pop = new SoundFile(this, "pop.mp3");
  
  // creating the initial bubbles
  for (int i = 0; i < MAX_BUBBLES; i++) {
    bubbles.add(new Bubble());
  }
}

void draw() {
  background(0);
  
  // update noise seed for bubble movement
  noise_offset += 0.01;
  
  // check and process all bubble objects
  for (int i = 0; i < bubbles.size(); i++) {
    
    // for each bubble, determine if it's under the mouse
    float distance = distance(
      mouseX, mouseY, bubbles.get(i).pos_x, bubbles.get(i).pos_y
    );
    
    // if under mouse, set "moused_over" field to "true"
    if (distance < BUBBLE_DIAMETER / 2) {
      bubbles.get(i).moused_over = true;
    } else {
      bubbles.get(i).moused_over = false;
    }
    
    // update each bubble's position and draw it
    bubbles.get(i).drawBubble(noise_offset);
    
    // remove off-screen bubbles
    if (bubbles.get(i).pos_x < -BUBBLE_DIAMETER / 2 || 
        bubbles.get(i).pos_x > width + BUBBLE_DIAMETER / 2 || 
        bubbles.get(i).pos_y < -BUBBLE_DIAMETER / 2 || 
        bubbles.get(i).pos_y > height + BUBBLE_DIAMETER / 2) {
          
      bubbles.remove(i);
    }
  }
  
  // check and process all splat objects
  for (int i = 0; i < splats.size(); i++) {
    
    // reduce the alpha to make splats fade
    splats.get(i).alpha -= 12.5; //<>//
    
    // render all splats
    if (splats.size() != 0) {
      splats.get(i).drawSplat();
    }
    
    // remove splats that are completely faded
    if (splats.get(i).alpha <= 0) {
      splats.remove(i);
    }
  }

  // add a random number of new bubbles every <APPEAR_INTERVAL> seconds
  if (frameCount % (APPEAR_INTERVAL * FRAMERATE) == 0 && 
      bubbles.size() < MAX_BUBBLES) {
        
    for (int i = 0; i < (int)random(1, NUM_APPEAR + 1); i++) {
      bubbles.add(new Bubble());
    }
  }
}

// handle mouse presses
void mousePressed() {
  
  // check if any bubbles are under the mouse when pressed
  for (int i = 0; i < bubbles.size(); i++) {
    
    // if bubble is under mouse when pressed, "pop" it
    if (bubbles.get(i).moused_over) {
      pop.play();
      splats.add(new Splat(bubbles.get(i).pos_x, bubbles.get(i).pos_y));
      bubbles.remove(i);
    }
  }
}

// calculates the distance between two points (distance formula)
float distance(float x1, float y1, float x2, float y2) {
  return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
}
