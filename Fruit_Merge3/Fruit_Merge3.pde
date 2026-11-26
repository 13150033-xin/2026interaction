
import java.util.ArrayList;

// ==========================================
// FRUIT MERGE - 繽紛糖果風
// Processing Java Mode
// 視窗：640 x 820
// ==========================================

final int MENU = 0;
final int PLAYING = 1;
final int GAMEOVER = 2;

int state = MENU;

// 字體
PFont font;

// 遊戲容器
float boxL = 45;
float boxR = 595;
float boxT = 190;
float boxB = 730;
float dangerY = 285;

// 七種水果
String[] fruitNames = {
  "藍莓", "檸檬", "奇異果",
  "蘋果", "橘子", "哈密瓜", "西瓜"
};

float[] fruitRadius = {
  25, 34, 43, 52, 61, 73, 88
};

color[] fruitColors = {
  color(125, 130, 245),
  color(255, 225, 90),
  color(120, 190, 105),
  color(255, 105, 115),
  color(255, 175, 65),
  color(155, 215, 125),
  color(75, 175, 105)
};

// 糖果風配色
color bgColor = color(255, 244, 248);
color pinkColor = color(255, 160, 190);
color purpleColor = color(175, 150, 245);
color blueColor = color(140, 200, 255);
color yellowColor = color(255, 220, 125);
color greenColor = color(145, 220, 175);

ArrayList<Fruit> fruits = new ArrayList<Fruit>();
ArrayList<Fruit> newFruits = new ArrayList<Fruit>();
ArrayList<Integer> leaderboard = new ArrayList<Integer>();

int score = 0;
int currentFruit = 0;
int nextFruit = 0;

int lastDropTime = 0;
int dropDelay = 450;

boolean gameSaved = false;

// ==========================================
// 初始化
// ==========================================

void setup() {
  size(640, 820);
  smooth(8);
  frameRate(60);

  font = createFont("Microsoft JhengHei", 20, true);
  textFont(font);
  textAlign(CENTER, CENTER);

  loadLeaderboard();

  currentFruit = int(random(0, 3));
  nextFruit = int(random(0, 3));
}

void draw() {
  background(bgColor);

  if (state == MENU) {
    drawMenu();
  }

  if (state == PLAYING) {
    drawGame();
  }

  if (state == GAMEOVER) {
    drawGame();
    drawGameOver();
  }
}

// ==========================================
// 主頁
// ==========================================

void drawMenu() {
  background(255, 242, 248);

  // 背景裝飾
  noStroke();

  fill(255, 210, 225);
  ellipse(35, 100, 140, 140);
  ellipse(605, 680, 160, 160);

  fill(220, 215, 255);
  ellipse(590, 90, 100, 100);
  ellipse(55, 740, 90, 90);

  fill(255, 230, 170);
  ellipse(500, 350, 45, 45);
  ellipse(110, 360, 35, 35);

  fill(180, 225, 255);
  ellipse(550, 500, 25, 25);
  ellipse(80, 510, 30, 30);

  // 標題
  fill(115, 90, 150);
  textSize(43);
  text("繽紛水果樂園", 320, 100);

  fill(245, 135, 175);
  textSize(21);
  text("FRUIT MERGE", 320, 145);

  // 星星裝飾
  drawStar(125, 165, 13, yellowColor);
  drawStar(510, 175, 13, yellowColor);
  drawStar(175, 300, 9, purpleColor);
  drawStar(465, 300, 9, blueColor);

  // 七種水果展示
  drawFruit(105, 250, 0, 0.8);
  drawFruit(175, 250, 1, 0.8);
  drawFruit(245, 250, 2, 0.8);
  drawFruit(315, 250, 3, 0.8);
  drawFruit(385, 250, 4, 0.8);
  drawFruit(455, 250, 5, 0.8);
  drawFruit(530, 250, 6, 0.8);

  // 遊戲介紹卡片
  noStroke();
  fill(255);
  rect(85, 365, 470, 145, 25);

  fill(165, 135, 180);
  textSize(22);
  text("準備好合成水果了嗎？", 320, 410);

  fill(125, 105, 145);
  textSize(16);
  text("挑戰七種水果，合成最大的西瓜！", 320, 450);

  textSize(14);
  fill(180, 145, 175);
  text("BLUEBERRY  •  LEMON  •  KIWI  •  WATERMELON",
       320, 480);

  // 開始按鈕
  drawButton(320, 610, 245, 65,
             "開始遊戲", pinkColor);

  // 排行榜
  fill(125, 100, 150);
  textSize(20);
  text("最高分排行榜", 320, 690);

  drawLeaderboard(730);

  fill(170, 145, 180);
  textSize(13);
  text("HAVE FUN WITH FRUIT!", 320, 785);
}

// ==========================================
// 遊戲畫面
// ==========================================

void drawGame() {
  background(255, 244, 248);

  // 標題
  fill(125, 90, 155);
  textSize(29);
  text("水果合成樂園", 320, 40);

  fill(235, 145, 180);
  textSize(13);
  text("FRUIT MERGE", 320, 68);

  // 分數卡片
  noStroke();
  fill(255);
  rect(35, 85, 230, 75, 18);

  fill(160, 130, 175);
  textSize(16);
  text("目前分數", 145, 105);

  fill(245, 125, 165);
  textSize(30);
  text(str(score), 145, 135);

  // 下一個水果
  fill(255);
  rect(375, 85, 230, 75, 18);

  fill(160, 130, 175);
  textSize(16);
  text("下一個水果", 450, 105);

  drawFruit(535, 125, nextFruit, 0.45);

  // 容器
  noStroke();
  fill(255);
  rect(boxL, boxT, boxR-boxL, boxB-boxT, 22);

  fill(255, 250, 252);
  rect(boxL+5, boxT+5,
       boxR-boxL-10, boxB-boxT-10, 18);

  fill(255, 230, 240);
  rect(boxL+5, boxT+5, boxR-boxL-10, 12, 5);

  // 危險線
  stroke(255, 105, 135);
  strokeWeight(2);

  for (int x = int(boxL+10); x < boxR-10; x += 20) {
    line(x, dangerY, x+10, dangerY);
  }

  noStroke();
  fill(255, 105, 135);
  textSize(13);
  text("DANGER 危險線", 500, dangerY-16);

  // 水果投放預覽
  if (state == PLAYING) {
    float r = fruitRadius[currentFruit];

    float previewX = constrain(
      mouseX, boxL+r+5, boxR-r-5
    );

    stroke(200, 180, 210);
    strokeWeight(2);
    line(previewX, boxT+15,
         previewX, boxB-10);

    noStroke();
    drawFruit(previewX, boxT+30,
              currentFruit, 0.75);
  }

  // 物理更新
  if (state == PLAYING) {
    updatePhysics();
    checkDanger();
  }

  // 水果顯示
  for (Fruit f : fruits) {
    f.display();
  }

  // 容器外框
  noFill();
  stroke(230, 190, 215);
  strokeWeight(5);
  rect(boxL, boxT, boxR-boxL,
       boxB-boxT, 22);

  // 底部
  noStroke();
  fill(255, 205, 225);
  rect(boxL, boxB, boxR-boxL, 10, 5);

  // 操作說明：只放在遊戲頁面
  fill(130, 105, 150);
  textSize(16);
  text("滑鼠移動：控制水果位置", 320, 765);

  textSize(15);
  text("空白鍵：投放水果       R鍵：重新開始", 320, 795);
}

// ==========================================
// 七種水果繪製
// ==========================================

void drawFruit(float x, float y, int type, float s) {

  pushMatrix();
  translate(x, y);
  scale(s);

  float r = fruitRadius[type];

  noStroke();

  // 陰影
  fill(180, 150, 175, 35);
  ellipse(3, r*0.85, r*1.7, r*0.35);

  // -------------------------
  // 藍莓
  // -------------------------
  if (type == 0) {

    fill(fruitColors[type]);
    ellipse(0, 0, r*2, r*2);

    fill(95, 105, 215);
    ellipse(-r*0.25, -r*0.78, r*0.55, r*0.3);
    ellipse(r*0.25, -r*0.78, r*0.55, r*0.3);

    fill(185, 190, 255);
    ellipse(0, -r*0.8, r*0.5, r*0.3);
  }

  // -------------------------
  // 檸檬
  // -------------------------
  if (type == 1) {

    fill(255, 220, 75);

    ellipse(0, 0, r*2, r*1.55);

    triangle(-r*0.85, 0,
             -r*1.15, -r*0.1,
             -r*0.8, r*0.18);

    triangle(r*0.85, 0,
             r*1.15, -r*0.1,
             r*0.8, r*0.18);

    fill(255, 245, 165);
    ellipse(-r*0.25, -r*0.25,
            r*0.65, r*0.25);

    fill(125, 195, 105);
    ellipse(r*0.15, -r*0.75,
            r*0.45, r*0.2);
  }

  // -------------------------
  // 奇異果
  // -------------------------
  if (type == 2) {

    // 外皮
    fill(135, 100, 65);
    ellipse(0, 0, r*2, r*2);

    // 果肉
    fill(150, 215, 100);
    ellipse(0, 0, r*1.65, r*1.65);

    // 中間果心
    fill(245, 235, 190);
    ellipse(0, 0, r*0.35, r*0.35);

    // 黑色籽點
    fill(55, 75, 45);

    for (int i = 0; i < 12; i++) {
      float a = TWO_PI*i/12;
      float sx = cos(a)*r*0.53;
      float sy = sin(a)*r*0.53;

      ellipse(sx, sy, r*0.09, r*0.13);
    }
  }

  // -------------------------
  // 蘋果
  // -------------------------
  if (type == 3) {

    fill(fruitColors[type]);

    ellipse(-r*0.35, 0, r*1.35, r*1.7);
    ellipse(r*0.35, 0, r*1.35, r*1.7);
    ellipse(0, r*0.2, r*1.8, r*1.45);

    fill(90, 190, 115);
    ellipse(r*0.2, -r*0.85,
            r*0.65, r*0.3);

    stroke(125, 90, 70);
    strokeWeight(3);
    line(0, -r*0.7, 0, -r*1.05);
    noStroke();
  }

  // -------------------------
  // 橘子
  // -------------------------
  if (type == 4) {

    fill(fruitColors[type]);
    ellipse(0, 0, r*2, r*2);

    fill(255, 210, 110);
    ellipse(-r*0.25, -r*0.25,
            r*0.4, r*0.3);

    fill(100, 190, 115);
    ellipse(r*0.2, -r*0.88,
            r*0.55, r*0.25);

    stroke(115, 95, 65);
    strokeWeight(3);
    line(0, -r*0.85, 0, -r*1.05);
    noStroke();
  }

  // -------------------------
  // 哈密瓜
  // 網狀外皮線條
  // -------------------------
  if (type == 5) {

    // 外皮
    fill(120, 185, 100);
    ellipse(0, 0, r*2, r*2);

    // 果肉底色
    fill(190, 230, 135);
    ellipse(0, 0, r*1.75, r*1.75);

    // 網狀紋路
    noFill();
    stroke(105, 175, 95, 190);
    strokeWeight(2.3);

    // 橫向弧線
    for (int i = -2; i <= 2; i++) {
      float yy = i*r*0.3;

      float ww = sqrt(max(0, r*r-yy*yy))*1.65;

      arc(0, yy, ww, r*0.35,
          PI, TWO_PI);
    }

    // 直向弧線
    for (int i = -2; i <= 2; i++) {
      float xx = i*r*0.3;

      float hh = sqrt(max(0, r*r-xx*xx))*1.65;

      arc(xx, 0, r*0.35, hh,
          HALF_PI, PI*1.5);
    }

    noStroke();

    // 中間高光
    fill(255, 255, 255, 65);
    ellipse(-r*0.35, -r*0.35,
            r*0.5, r*0.2);
  }
  
   
  // -------------------------
  // 條紋圓西瓜
  // 規則縱向弧形條紋
  // -------------------------
  if (type == 6) {

    // 西瓜圓形外框
    float watermelonR = r;

    // 基底深綠色
    noStroke();
    fill(45, 140, 75);
    ellipse(0, 0,
            watermelonR*2,
            watermelonR*2);

    // 淺綠色果皮
    fill(115, 200, 115);
    ellipse(0, 0,
            watermelonR*1.94,
            watermelonR*1.94);

    // 建立圓形裁切遮罩
    // 條紋不會超出西瓜外框
    PGraphics stripeLayer = createGraphics(
      int(watermelonR*2+4),
      int(watermelonR*2+4)
    );

    stripeLayer.beginDraw();
    stripeLayer.clear();
    stripeLayer.smooth(8);

    stripeLayer.translate(
      stripeLayer.width/2,
      stripeLayer.height/2
    );

    // 縱向弧形條紋
    stripeLayer.noFill();
    stripeLayer.stroke(45, 140, 75);
    stripeLayer.strokeWeight(5);

    // 每條條紋位置對稱且等距
    int stripeCount = 7;

    for (int i = -3; i <= 3; i++) {

      float offset = i * watermelonR * 0.24;

      // 越靠近兩側，弧度越明顯
      float curve = offset * 0.48;

      stripeLayer.beginShape();

      // 由上往下繪製
      for (int j = 0; j <= 40; j++) {

        float t = map(j, 0, 40, -1, 1);

        // 沿圓形表面向內彎曲
        float px = offset * cos(t * HALF_PI)
                   + curve * sin(t * HALF_PI);

        float py = t * watermelonR * 1.12;

        // 限制在圓形範圍內
        float limitX = sqrt(
          max(0,
          watermelonR*watermelonR - py*py)
        );

        px = constrain(px, -limitX, limitX);

        stripeLayer.curveVertex(px, py);
      }

      stripeLayer.endShape();
    }

    stripeLayer.endDraw();

    // 建立圓形遮罩
    PGraphics maskLayer = createGraphics(
      stripeLayer.width,
      stripeLayer.height
    );

    maskLayer.beginDraw();
    maskLayer.clear();
    maskLayer.noStroke();
    maskLayer.fill(255);
    maskLayer.ellipse(
      maskLayer.width/2,
      maskLayer.height/2,
      watermelonR*1.94,
      watermelonR*1.94
    );
    maskLayer.endDraw();

    // 套用遮罩
    PImage stripeImage = stripeLayer.get();
    stripeImage.mask(maskLayer.get());

    imageMode(CENTER);
    image(stripeImage, 0, 0);
    imageMode(CORNER);

    // 外框細緻描邊
    noFill();
    stroke(45, 135, 75);
    strokeWeight(2);
    ellipse(0, 0,
            watermelonR*1.94,
            watermelonR*1.94);

    noStroke();

    // 柔和高光
    fill(255, 255, 255, 75);
    ellipse(-watermelonR*0.38,
            -watermelonR*0.42,
            watermelonR*0.45,
            watermelonR*0.2);
  }

  // -------------------------
  // 條紋圓西瓜
  // 規則縱向弧形條紋
  // -------------------------
  if (type == 6) {

    // 圓形西瓜外皮
    fill(45, 145, 85);
    ellipse(0, 0, r*2, r*2);

    // 西瓜淺綠底色
    fill(105, 200, 120);
    ellipse(0, 0, r*1.88, r*1.88);

    // 縱向弧形條紋
    // 每條線間距與粗細一致
    stroke(38, 135, 77);
    strokeWeight(5);
    noFill();

    int stripeCount = 7;

    for (int i = 0; i < stripeCount; i++) {

      // 從左到右均勻分布
      float offset = map(
        i, 0, stripeCount-1,
        -0.78, 0.78
      );

      // 每條弧線使用獨立路徑
      beginShape();

      // 從頂部往下延伸
      for (int j = 0; j <= 60; j++) {

        float t = map(j, 0, 60, -1, 1);

        // 圓形表面輪廓
        float surfaceX =
          offset * sqrt(max(0, 1-t*t));

        // 條紋自然向內彎曲
        float curve =
          offset * 0.20 * (1-t*t);

        float sx =
          r * (surfaceX + curve);

        float sy =
          r * t * 0.94;

        // 限制線條在圓形範圍內
        float limit =
          sqrt(max(0, 1-
          (sy*sy)/(r*r)));

        sx = constrain(
          sx,
          -r*limit,
          r*limit
        );

        vertex(sx, sy);
      }

      endShape();
    }

    noStroke();

    // 西瓜表面柔和高光
    fill(255, 255, 255, 75);
    ellipse(-r*0.38, -r*0.38,
            r*0.42, r*0.2);
  }


  

  // -------------------------
  // 統一可愛表情
  // -------------------------

  // 高光
  fill(255, 255, 255, 125);
  ellipse(-r*0.35, -r*0.4,
          r*0.45, r*0.22);

  // 眼睛
  fill(75, 65, 95);
  ellipse(-r*0.28, -r*0.03,
          r*0.13, r*0.19);

  ellipse(r*0.28, -r*0.03,
          r*0.13, r*0.19);

  // 眼睛高光
  fill(255);
  ellipse(-r*0.30, -r*0.08,
          r*0.045, r*0.06);

  ellipse(r*0.26, -r*0.08,
          r*0.045, r*0.06);

  // 腮紅
  fill(255, 110, 150, 130);
  ellipse(-r*0.48, r*0.2,
          r*0.28, r*0.16);

  ellipse(r*0.48, r*0.2,
          r*0.28, r*0.16);

  // 微笑
  noFill();
  stroke(85, 60, 85);
  strokeWeight(2.5);
  arc(0, r*0.13, r*0.3, r*0.22, 0, PI);

  noStroke();

  popMatrix();
}

// ==========================================
// 水果類別
// ==========================================

class Fruit {

  float x, y;
  float vx, vy;
  float r;

  int type;

  boolean removed = false;

  // 是否已完整進入危險線下方
  boolean passedDangerLine = false;

  Fruit(float x, float y, int type) {

    this.x = x;
    this.y = y;
    this.type = type;

    r = fruitRadius[type];

    vx = 0;
    vy = 0;
  }

  void display() {
    drawFruit(x, y, type, 1);
  }
}

// ==========================================
// 投放水果
// ==========================================

void dropFruit() {

  if (state != PLAYING) return;

  if (millis()-lastDropTime < dropDelay) return;

  float r = fruitRadius[currentFruit];

  float x = constrain(
    mouseX,
    boxL+r+5,
    boxR-r-5
  );

  Fruit f = new Fruit(x, boxT+35, currentFruit);

  f.vy = 1.5;

  fruits.add(f);

  currentFruit = nextFruit;

  // 只從前三階段產生水果
  nextFruit = int(random(0, 3));

  lastDropTime = millis();
}

// ==========================================
// 物理系統
// ==========================================

void updatePhysics() {

  // 重力
  for (Fruit f : fruits) {

    f.vy += 0.38;
    f.vy = min(f.vy, 13);

    f.x += f.vx;
    f.y += f.vy;

    f.vx *= 0.99;
    f.vy *= 0.995;

    // 左邊界
    if (f.x-f.r < boxL+5) {
      f.x = boxL+5+f.r;
      f.vx = abs(f.vx)*0.35;
    }

    // 右邊界
    if (f.x+f.r > boxR-5) {
      f.x = boxR-5-f.r;
      f.vx = -abs(f.vx)*0.35;
    }

    // 底部
    if (f.y+f.r > boxB) {

      f.y = boxB-f.r;

      if (f.vy > 1) {
        f.vy *= -0.15;
      } else {
        f.vy = 0;
      }

      f.vx *= 0.85;
    }

    // 確認水果已完整通過危險線
    if (f.y-f.r > dangerY) {
      f.passedDangerLine = true;
    }
  }

  // 碰撞及合成
  for (int i = 0; i < fruits.size(); i++) {

    Fruit a = fruits.get(i);

    if (a.removed) continue;

    for (int j = i+1; j < fruits.size(); j++) {

      Fruit b = fruits.get(j);

      if (b.removed) continue;

      float dx = b.x-a.x;
      float dy = b.y-a.y;

      float dist = sqrt(dx*dx+dy*dy);

      if (dist == 0) {
        dx = 0.1;
        dist = 0.1;
      }

      float minDist = a.r+b.r;

      if (dist < minDist) {

        float nx = dx/dist;
        float ny = dy/dist;

        float overlap = minDist-dist;

        // 推開水果
        a.x -= nx*overlap*0.5;
        a.y -= ny*overlap*0.5;

        b.x += nx*overlap*0.5;
        b.y += ny*overlap*0.5;

        // 碰撞速度
        float relative =
          (b.vx-a.vx)*nx+(b.vy-a.vy)*ny;

        if (relative < 0) {

          float impulse = -relative*0.35;

          a.vx -= impulse*nx;
          a.vy -= impulse*ny;

          b.vx += impulse*nx;
          b.vy += impulse*ny;
        }

        // 同種類水果合成
        if (a.type == b.type &&
            a.type < 6) {

          a.removed = true;
          b.removed = true;

          Fruit nf = new Fruit(
            (a.x+b.x)*0.5,
            (a.y+b.y)*0.5,
            a.type+1
          );

          nf.vy = -1.5;
          nf.vx = (a.vx+b.vx)*0.5;

          newFruits.add(nf);

          score += (a.type+1)*20;
        }
      }
    }
  }

  // 移除舊水果
  for (int i = fruits.size()-1; i >= 0; i--) {

    if (fruits.get(i).removed) {
      fruits.remove(i);
    }
  }

  // 加入合成水果
  for (Fruit f : newFruits) {
    fruits.add(f);
  }

  newFruits.clear();

  // 最後修正邊界
  for (Fruit f : fruits) {

    f.x = constrain(
      f.x,
      boxL+f.r+5,
      boxR-f.r-5
    );

    if (f.y+f.r > boxB) {
      f.y = boxB-f.r;
      f.vy = 0;
    }
  }
}

// ==========================================
// 危險線判定
// ==========================================

void checkDanger() {

  for (Fruit f : fruits) {

    // 已經從上方完整進入容器的水果
    // 只要之後又超過危險線，就立即結束
    if (f.passedDangerLine &&
        f.y-f.r < dangerY) {

      endGame();
      return;
    }
  }
}

// ==========================================
// 遊戲結束
// ==========================================

void endGame() {

  if (state != PLAYING) return;

  state = GAMEOVER;

  if (!gameSaved) {
    addScore(score);
    gameSaved = true;
  }
}

// ==========================================
// 遊戲結束畫面
// ==========================================

void drawGameOver() {

  fill(90, 75, 110, 145);
  noStroke();
  rect(0, 0, width, height);

  // 卡片
  fill(255, 248, 252);
  stroke(255, 195, 220);
  strokeWeight(3);
  rect(85, 245, 470, 350, 28);

  noStroke();

  fill(235, 125, 165);
  textSize(39);
  text("遊戲結束！", 320, 305);

  fill(145, 115, 165);
  textSize(19);
  text("你的本次分數", 320, 370);

  fill(245, 125, 165);
  textSize(38);
  text(str(score), 320, 415);

  fill(150, 120, 170);
  textSize(17);
  text("水果超過危險線了！", 320, 470);

  fill(150, 120, 170);
  textSize(20);
  text("最高分排行榜", 320, 525);

  drawLeaderboard(560);

  fill(235, 125, 165);
  textSize(18);
  text("按下 R 鍵重新開始", 320, 625);
}

// ==========================================
// 按鈕
// ==========================================

void drawButton(float x, float y,
                float w, float h,
                String label, color c) {

  rectMode(CENTER);

  noStroke();
  fill(210, 180, 205);
  rect(x, y+4, w, h, 25);

  fill(c);
  rect(x, y, w, h, 25);

  fill(255);
  textSize(22);
  text(label, x, y);

  rectMode(CORNER);
}

boolean buttonHit(float x, float y,
                  float w, float h) {

  return mouseX >= x-w/2 &&
         mouseX <= x+w/2 &&
         mouseY >= y-h/2 &&
         mouseY <= y+h/2;
}

// ==========================================
// 排行榜
// ==========================================

void addScore(int s) {

  leaderboard.add(s);

  for (int i = 0; i < leaderboard.size(); i++) {

    for (int j = i+1; j < leaderboard.size(); j++) {

      if (leaderboard.get(j) > leaderboard.get(i)) {

        int temp = leaderboard.get(i);

        leaderboard.set(i, leaderboard.get(j));
        leaderboard.set(j, temp);
      }
    }
  }

  while (leaderboard.size() > 5) {
    leaderboard.remove(leaderboard.size()-1);
  }

  saveLeaderboard();
}

void drawLeaderboard(float y) {

  fill(145, 115, 165);
  textSize(15);

  if (leaderboard.size() == 0) {

    text("尚無遊戲紀錄", 320, y);

  } else {

    for (int i = 0; i < min(3, leaderboard.size()); i++) {

      String medal = "";

      if (i == 0) medal = "第 1 名";
      if (i == 1) medal = "第 2 名";
      if (i == 2) medal = "第 3 名";

      text(medal + "     " +
           leaderboard.get(i) + " 分",
           320, y+i*24);
    }
  }
}

void saveLeaderboard() {

  String[] data = new String[leaderboard.size()];

  for (int i = 0; i < leaderboard.size(); i++) {
    data[i] = str(leaderboard.get(i));
  }

  saveStrings("leaderboard.txt", data);
}

void loadLeaderboard() {

  String[] data = loadStrings("leaderboard.txt");

  if (data == null) return;

  for (int i = 0; i < data.length; i++) {

    try {
      leaderboard.add(int(data[i]));
    } catch(Exception e) {
    }
  }
}

// ==========================================
// 星星裝飾
// ==========================================

void drawStar(float x, float y,
              float r, color c) {

  pushMatrix();
  translate(x, y);

  fill(c);
  noStroke();

  beginShape();

  for (int i = 0; i < 10; i++) {

    float angle = TWO_PI*i/10-PI/2;

    float radius = (i%2 == 0) ? r : r*0.45;

    vertex(cos(angle)*radius,
           sin(angle)*radius);
  }

  endShape(CLOSE);

  popMatrix();
}

// ==========================================
// 重新開始
// ==========================================

void restartGame() {

  fruits.clear();
  newFruits.clear();

  score = 0;

  currentFruit = int(random(0, 3));
  nextFruit = int(random(0, 3));

  lastDropTime = 0;

  gameSaved = false;

  state = PLAYING;
}

// ==========================================
// 滑鼠事件
// ==========================================

void mousePressed() {

  if (state == MENU) {

    if (buttonHit(320, 610, 245, 65)) {
      restartGame();
    }
  }
}

// ==========================================
// 鍵盤事件
// ==========================================

void keyPressed() {

  if (key == 'r' || key == 'R') {
    restartGame();
  }

  if (key == ' ' && state == PLAYING) {
    dropFruit();
  }

  if (key == ENTER && state == MENU) {
    restartGame();
  }
}
