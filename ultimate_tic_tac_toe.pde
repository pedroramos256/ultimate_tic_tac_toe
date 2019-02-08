/*

Ultimate Tic Tac Toe

Designed by Pedro Ramos

*/

Game game;
boolean player = true; //defines who plays next, true = player1, false = player0
int ci = -1,cj; // ci starts at -1 to allow the first player to anywhere
int tempmx1, tempmy1; // variables to temporarily save mx1 and my1
Button rules;

void setup(){
  size(800,900);
  frameRate(10);
  textAlign(CENTER);
  rules = new Button(width/2,(height-width)/2,width/10,width/20,"RULES");
  // creating an empty game
  game = new Game(width,0,100);
  game.create_games();
  game.create_cels();
}

void draw(){
  background(255);
  stroke(127);
  // displays the board and the rules button
  game.display();
  rules.display();
  // if mouse is inside the rules button, then display the text with the rules
  if(rules.in()){
    stroke(127);
    game.display();// still displays the board, in order to do a frosted effect
    fill(255,200);
    noStroke();
    rect(0,0,width,height);
    fill(0);
    text("You start by playing in any mini game \n Your oponent must play on the mini game that your coordinate indicates",width/2,height/2);
    text("If your coordinate indicates a finished mini game, \n your oponent can choose any free mini game \n Wins who finishes first the big game",width/2,height/2+60);
  }
}

void mousePressed(){
  int mx,my;
  int mx1,my1;
  mx = int((mouseX-game.xi)/(game.sca/3));
  my = int((mouseY-game.yi)/(game.sca/3));
  mx1 = int(((mouseX-game.xi)-mx*game.sca/3)/(game.games[mx][my].sca/3));
  my1 = int(((mouseY-game.yi)-my*game.sca/3)/(game.games[mx][my].sca/3));
  if(mouseY >= game.yi && (ci == -1 || game.cel[mx][my].est == -1 && ((mx == ci && my == cj) || game.cel[tempmx1][tempmy1].est != -1))){
    tempmx1 = mx1;
    tempmy1 = my1;
    ci = mx1;
    cj = my1;
    if(game.games[mx][my].cel[mx1][my1].est == -1){
      game.games[mx][my].cel[mx1][my1].est = int(player);
      player ^= true;//xor
    }
  }
  // verifies if any of the mini games is completed
  for(int i = 0;i < 3;i++){
    for(int j = 0;j < 3;j++){
      game.verify_winner(game.games[i][j],i,j);
    }
  }
  // verifies if someones won the big game
  game.verify_winner(game,3,3);
}

void keyPressed(){
  // restart game
  if(keyCode == ENTER){
    stroke(127);
    game = new Game(width,0,100);
    game.create_games();
    game.create_cels();
    ci = -1;
    loop();
  }
}

class Button{
  int x,y,sx,sy;
  String t;
  Button(int tempx, int tempy, int tempsx, int tempsy, String tempt){
    x = tempx;
    y = tempy;
    sx = tempsx;
    sy = tempsy;
    t = tempt;
  }
  // draws the button
  void display(){
    rectMode(CENTER);
    rect(x,y,sx,sy,sx/5);
    rectMode(CORNER);
    textSize(sy/2);
    fill(0);
    text(t,x,y+sy/5);
  }
  // verifies if mouse is inside the button
  boolean in(){
    return mouseX >= x-sx/2 && mouseX <= x+sx/2 && mouseY >= y-sy/2 && mouseY <= y+sy/2;
  }
}
  
    
class Game{
  float sca;
  int xi;
  int yi;
  Game [][] games = new Game[3][3]; // array of the mini games
  Cel [][] cel = new Cel[3][3]; // array of the cels, in the big game a cel is a mini game    

  class Cel{
    int est = -1;// -1 means it's empty
    int x;
    int y;
    Cel(int tempX, int tempY){
      x = tempX;
      y = tempY;
    }
    // diplays one cel, either empty, with a cross or with a circle
    void display_cel(){
      strokeWeight(1);
      rect(x,y,sca/3,sca/3);
      strokeWeight(5);
      if(est == 0){ // circle
        ellipseMode(CENTER);
        ellipse(x+sca/6,y+sca/6,sca/6,sca/6);
      }else if(est == 1){ // cross
        rectMode(CENTER);
        translate(x+sca/6,y+sca/6);
        rotate(PI/4);
        rect(0,0,sca/6,sca/24);
        rect(0,0,sca/24,sca/6);
        rotate(-PI/4);
        translate(-(x+sca/6),-(y+sca/6));
        rectMode(CORNER);
      }
    }
  }
  Game(float tempSca, int tempXi, int tempYi){
    sca = tempSca;
    xi = tempXi;
    yi = tempYi;
  }
  // fills the array of games with mini games
  void create_games(){
    for(int i = 0; i < 3;i++){
      for(int j = 0; j < 3;j++){
       games[i][j] = new Game(sca/3,int(xi+i*sca/3),int(yi+j*sca/3));
       games[i][j].create_cels();
      }
    }
  }
  // fills the array of cels width cels
  void create_cels(){
    for(int i = 0; i < 3;i++){
      for(int j = 0; j < 3;j++){
       cel[i][j] = new Cel(xi+int(i*sca/3),yi+int(j*sca/3));
      }
    }
  }
  // displays all cels
  void display(){
    for(int ki = 0;ki < 3;ki++){
      for(int kj = 0;kj < 3;kj++){
        for(int i = 0; i < 3;i++){
          for(int j = 0; j < 3;j++){
            strokeWeight(5);
            noFill();
            rect(games[ki][kj].xi,games[ki][kj].yi,games[ki][kj].sca,games[ki][kj].sca);
            games[ki][kj].cel[i][j].display_cel();
          }
        }
      }
    }
  }
  // verifies if there's a winner of a mini game, or of the big game, depends on which object is placed 
  void verify_winner(Game mini_game,int i, int j){
    int winner = -1; // means there's no winner
    boolean win = false;
    for(int r = 0;r < 2;r++){
      for(int k = 0;k < 3;k++){
        // long series of conditions that verifies if a line(t = 0) or column(r = 1) is finished
        if(mini_game.cel[k][k].est != -1 && ((r == 0 && mini_game.cel[k][0].est == mini_game.cel[k][1].est && mini_game.cel[k][0].est == mini_game.cel[k][2].est) || (r == 1 && mini_game.cel[0][k].est == mini_game.cel[1][k].est && mini_game.cel[0][k].est == mini_game.cel[2][k].est))){
            win = true;
            winner = mini_game.cel[k][k].est;
            break;
        }
      }
      // condition to skip both cicles in case of winning
      if(win){
        break;
      }
    }
    // long series of conditions to verifie if one of the diagonals is finished
    if((mini_game.cel[0][0].est == mini_game.cel[1][1].est && mini_game.cel[2][2].est == mini_game.cel[1][1].est) || (mini_game.cel[2][0].est == mini_game.cel[1][1].est && mini_game.cel[0][2].est == mini_game.cel[1][1].est)){
      win = true;
      winner = mini_game.cel[1][1].est;
    }
    if(win && winner != -1){
      if(i != 3){
        // changes the state of the the cel of the big game that corresponds to the mini game finished
        game.cel[i][j].est = winner;
        // displays a big symbol of the player that won the mini game
        fill(250,100);
        rect(mini_game.xi,mini_game.yi,mini_game.sca,mini_game.sca); // frosted effect
        game.cel[i][j].display_cel();
      // if i == 3, means that it is the big game, so it's the end of the game
      }else{
        // ends the game and asks for restart
        fill(200,100);
        noStroke();
        rectMode(CORNER);
        rect(0,0,width,height);
        fill(0);
        textSize(32);
        text("Winner is player "+winner+"\n press ENTER to restart",width/2,height/2);
        noLoop();
      }
    }
  }
}
