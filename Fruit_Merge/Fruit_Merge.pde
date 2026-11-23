
import javax.sound.sampled.*;

// ============================================
// 合成水果遊戲 Fruit Merge
// Processing Java Mode
// 視窗大小：640 x 820
// 不需要外部圖片或音效素材
// ============================================

final int W = 640;
final int H = 820;

// 遊戲容器
final float BOX_LEFT = 45;
final float BOX_RIGHT = 595;
final float BOX_TOP = 170;
final float BOX_BOTTOM = 765;

// 危險線
final float DANGER_LINE = 260;

// 遊戲狀態
boolean gameOver = false;
int score = 0;
int dangerFrames = 0;
int collisionCooldown = 0;
int dropCooldown = 0;

// 水果陣列
ArrayList<Fruit> fruits = new ArrayList<Fruit>();

// 水果顏色
color[] fruitColors = {
  color(170, 105, 210),
  color(100, 160, 245),
  color(255, 165, 75),
  color(235, 75, 90),
  color(255, 145, 165),
  color(180, 215, 110),
  color(245, 195, 55),
  color(125, 195, 105),
  color(235, 95, 115),
  color(220, 75, 95),
  color(175, 90, 170)
};

// 水果名稱
String[] fruitNames = {
  "葡萄", "藍莓", "橘子", "蘋果",
  "桃子", "梨子", "鳳梨", "哈密瓜",
  "西瓜", "大西瓜", "皇冠西瓜"
};

// 水果大小
float[] fruitSizes = {
  17, 23, 30, 37, 44, 52,
  62, 73, 85, 98, 112
};

// 水果分數
int[] fruitScores = {
  2, 4, 8, 16, 32, 64,
  128, 256, 512, 1024, 2048
};

// 當前水果及下一個水果
int currentFruit;
int nextFruit;

// 字體
PFont gameFont;


// ============================================
// 初始化
// ============================================

void setup() {

  size(640, 820);
  smooth(8);

  gameFont = createFont("SansSerif", 20);
  textFont(gameFont);

  startGame();
}


// ============================================
// 遊戲主程式
// ============================================

void draw() {

  drawBackground();
  drawHeader();
  drawGameBox();

  if (!gameOver) {
    updateGame();
  }

  drawFruits();

  if (!gameOver) {
    drawDropPreview();
    drawNextFruit();
  } else {
    drawGameOver();
  }

  if (dropCooldown > 0) {
    dropCooldown--;
  }

  if (collisionCooldown > 0) {
    collisionCooldown--;
  }
}


// ============================================
// 背景
// ============================================

void drawBackground() {

  background(255, 242, 225);

  noStroke();

  fill(255, 221, 198);
  ellipse(35, 340, 35, 35);
  ellipse(610, 390, 42, 42);
  ellipse(20, 680, 25, 25);
  ellipse(620, 700, 30, 30);

  fill(255, 228, 210);
  ellipse(570, 105, 65, 65);
  ellipse(65, 100, 55, 55);
}


// ============================================
// 標題及分數
// ============================================

void drawHeader() {

  textAlign(CENTER, CENTER);

  fill(120, 75, 65);
  textSize(32);
  text("合成水果樂園", width/2, 45);

  // 分數面板
  noStroke();
  fill(255);
  rect(65, 85, 225, 65, 18);

  // 下一個水果面板
  fill(255, 235, 215);
  rect(350, 85, 225, 65, 18);

  fill(150, 90, 70);
  textSize(16);
  text("CURRENT SCORE", 177, 103);

  fill(235, 125, 80);
  textSize(25);
  text(score, 177, 130);

  fill(150, 90, 70);
  textSize(16);
  text("NEXT FRUIT", 420, 110);

  fill(255, 150, 100);
  textSize(13);
  text(fruitNames[nextFruit], 420, 132);
}


// ============================================
// 遊戲容器
// ============================================

void drawGameBox() {

  stroke(225, 165, 135);
  strokeWeight(5);

  fill(255, 251, 240);

  rect(
    BOX_LEFT,
    BOX_TOP,
    BOX_RIGHT - BOX_LEFT,
    BOX_BOTTOM - BOX_TOP,
    20
  );

  // 危險線
  stroke(245, 100, 105);
  strokeWeight(2);

  drawDashedLine(
    BOX_LEFT + 8,
    DANGER_LINE,
    BOX_RIGHT - 8,
    DANGER_LINE
  );

  noStroke();

  fill(230, 95, 100);
  textAlign(LEFT);
  textSize(13);

  text(
    "危險區域",
    BOX_LEFT + 12,
    DANGER_LINE - 12
  );

  // 容器底部
  fill(245, 225, 205);

  rect(
    BOX_LEFT + 5,
    BOX_BOTTOM - 12,
    BOX_RIGHT - BOX_LEFT - 10,
    8,
    5
  );
}


// ============================================
// 虛線繪製
// ============================================

void drawDashedLine(
  float x1, float y1,
  float x2, float y2
) {

  float distance = dist(x1, y1, x2, y2);
  float step = 12;

  for (float d = 0; d < distance; d += step) {

    float end = min(d + 6, distance);

    float sx = lerp(x1, x2, d / distance);
    float sy = lerp(y1, y2, d / distance);

    float ex = lerp(x1, x2, end / distance);
    float ey = lerp(y1, y2, end / distance);

    line(sx, sy, ex, ey);
  }
}


// ============================================
// 更新遊戲
// ============================================

void updateGame() {

  // 更新水果
  for (Fruit f : fruits) {
    f.update();
  }

  // 碰撞及合成
  for (int pass = 0; pass < 4; pass++) {

    boolean merged = false;

    for (int i = 0; i < fruits.size() && !merged; i++) {

      Fruit a = fruits.get(i);

      for (int j = i + 1; j < fruits.size(); j++) {

        Fruit b = fruits.get(j);

        float dx = b.x - a.x;
        float dy = b.y - a.y;

        float distance = sqrt(dx * dx + dy * dy);

        float minDistance = a.r + b.r;

        // 相同水果合成
        if (distance < minDistance &&
            a.level == b.level &&
            a.level < fruitSizes.length - 1) {

          mergeFruits(i, j);

          merged = true;
          break;
        }

        // 不同水果碰撞
        if (distance < minDistance) {

          resolveCollision(a, b, distance);
        }
      }
    }
  }

  // 危險線判斷
  boolean danger = false;

  for (Fruit f : fruits) {

    if (f.y - f.r < DANGER_LINE &&
        abs(f.vy) < 0.8 &&
        f.age > 90) {

      danger = true;
      break;
    }
  }

  if (danger) {
    dangerFrames++;
  } else {
    dangerFrames = 0;
  }

  // 超過危險線一定時間
  if (dangerFrames > 90) {

    gameOver = true;

    playSound(260, 400);
  }
}


// ============================================
// 水果碰撞物理
// ============================================

void resolveCollision(Fruit a, Fruit b, float distance) {

  float dx = b.x - a.x;
  float dy = b.y - a.y;

  if (distance < 0.001) {

    dx = 0.01;
    dy = 0.01;

    distance = 0.014;
  }

  float nx = dx / distance;
  float ny = dy / distance;

  float overlap = a.r + b.r - distance;

  // 分離水果，避免重疊
  a.x -= nx * overlap * 0.5;
  a.y -= ny * overlap * 0.5;

  b.x += nx * overlap * 0.5;
  b.y += ny * overlap * 0.5;

  // 計算相對速度
  float relativeX = b.vx - a.vx;
  float relativeY = b.vy - a.vy;

  float velocity = relativeX * nx + relativeY * ny;

  if (velocity < 0) {

    float restitution = 0.28;

    float impulse =
      -(1 + restitution) * velocity / 2;

    a.vx -= impulse * nx;
    a.vy -= impulse * ny;

    b.vx += impulse * nx;
    b.vy += impulse * ny;

    // 碰撞音效
    if (collisionCooldown <= 0) {

      playSound(240, 35);
      collisionCooldown = 8;
    }
  }
}


// ============================================
// 水果合成
// ============================================

void mergeFruits(int i, int j) {

  Fruit a = fruits.get(i);
  Fruit b = fruits.get(j);

  int newLevel = a.level + 1;

  float newX = (a.x + b.x) / 2;
  float newY = (a.y + b.y) / 2;

  float newVX = (a.vx + b.vx) / 2;
  float newVY = (a.vy + b.vy) / 2;

  // 移除舊水果
  fruits.remove(j);
  fruits.remove(i);

  // 建立新水果
  Fruit newFruit = new Fruit(
    newX,
    newY,
    newLevel
  );

  newFruit.vx = newVX;
  newFruit.vy = newVY - 1.5;

  fruits.add(newFruit);

  // 增加分數
  score += fruitScores[newLevel];

  // 合成音效
  playSound(880, 100);

  // 第二段音效
  playSound(1175, 130);
}


// ============================================
// 水果類別
// ============================================

class Fruit {

  float x, y;
  float vx, vy;
  float r;

  int level;
  int age = 0;

  Fruit(float x, float y, int level) {

    this.x = x;
    this.y = y;
    this.level = level;

    r = fruitSizes[level];

    vx = 0;
    vy = 0;
  }

  void update() {

    age++;

    // 重力
    vy += 0.42;

    // 空氣阻力
    vx *= 0.995;

    // 更新位置
    x += vx;
    y += vy;

    // 左邊界
    if (x - r < BOX_LEFT + 5) {

      x = BOX_LEFT + 5 + r;

      vx = abs(vx) * 0.35;
    }

    // 右邊界
    if (x + r > BOX_RIGHT - 5) {

      x = BOX_RIGHT - 5 - r;

      vx = -abs(vx) * 0.35;
    }

    // 底部碰撞
    if (y + r > BOX_BOTTOM - 12) {

      y = BOX_BOTTOM - 12 - r;

      vy *= -0.25;

      if (abs(vy) < 0.7) {
        vy = 0;
      }

      vx *= 0.96;
    }

    // 上方邊界
    if (y - r < BOX_TOP + 5) {

      y = BOX_TOP + 5 + r;

      vy = max(0, vy);
    }
  }

  void display() {

    drawFruitShape(
      x,
      y,
      r,
      level
    );
  }
}


// ============================================
// 水果卡通繪製
// ============================================

void drawFruitShape(
  float x,
  float y,
  float r,
  int level
) {

  pushMatrix();

  translate(x, y);

  noStroke();

  // 水果陰影
  fill(120, 80, 70, 35);

  ellipse(
    3,
    r * 0.85,
    r * 1.7,
    r * 0.35
  );

  // 水果本體
  fill(fruitColors[level]);

  ellipse(
    0,
    0,
    r * 2,
    r * 2
  );

  // 水果高光
  fill(255, 255, 255, 90);

  ellipse(
    -r * 0.35,
    -r * 0.38,
    r * 0.35,
    r * 0.23
  );

  // 葉子
  if (level >= 3) {

    fill(90, 175, 90);

    ellipse(
      0,
      -r * 0.91,
      r * 0.7,
      r * 0.25
    );

    stroke(65, 140, 75);
    strokeWeight(2);

    line(
      0,
      -r * 0.8,
      0,
      -r * 1.05
    );

    noStroke();
  }

  // 眼睛位置
  float eyeY = r * 0.05;
  float eyeX = r * 0.30;

  // 眼睛
  fill(75, 55, 55);

  ellipse(
    -eyeX,
    eyeY,
    r * 0.13,
    r * 0.19
  );

  ellipse(
    eyeX,
    eyeY,
    r * 0.13,
    r * 0.19
  );

  // 眼睛高光
  fill(255);

  ellipse(
    -eyeX - 1,
    eyeY - 2,
    r * 0.045,
    r * 0.06
  );

  ellipse(
    eyeX - 1,
    eyeY - 2,
    r * 0.045,
    r * 0.06
  );

  // 腮紅
  fill(255, 130, 145, 150);

  ellipse(
    -r * 0.52,
    r * 0.30,
    r * 0.25,
    r * 0.13
  );

  ellipse(
    r * 0.52,
    r * 0.30,
    r * 0.25,
    r * 0.13
  );

  // 微笑
  noFill();

  stroke(100, 55, 55);

  strokeWeight(max(1.5, r * 0.045));

  arc(
    0,
    r * 0.10,
    r * 0.45,
    r * 0.40,
    0.15,
    PI - 0.15
  );

  noStroke();

  popMatrix();
}


// ============================================
// 顯示所有水果
// ============================================

void drawFruits() {

  for (Fruit f : fruits) {

    f.display();
  }
}


// ============================================
// 掉落水果預覽
// ============================================

void drawDropPreview() {

  float dropX = constrain(
    mouseX,
    BOX_LEFT + fruitSizes[currentFruit] + 5,
    BOX_RIGHT - fruitSizes[currentFruit] - 5
  );

  // 掉落位置虛線
  stroke(220, 180, 150, 150);
  strokeWeight(2);

  drawDashedLine(
    dropX,
    BOX_TOP + 15,
    dropX,
    BOX_BOTTOM
  );

  // 預覽水果
  drawFruitShape(
    dropX,
    BOX_TOP + 35,
    fruitSizes[currentFruit],
    currentFruit
  );

  // 提示文字
  fill(160, 120, 100);

  noStroke();

  textAlign(CENTER);
  textSize(14);

  text(
    "點擊滑鼠放下水果！",
    width/2,
    795
  );
}


// ============================================
// 下一個水果預覽
// ============================================

void drawNextFruit() {

  drawFruitShape(
    520,
    117,
    fruitSizes[nextFruit] * 0.42,
    nextFruit
  );
}


// ============================================
// 放下水果
// ============================================

void dropFruit() {

  if (gameOver || dropCooldown > 0) {
    return;
  }

  float x = constrain(
    mouseX,
    BOX_LEFT + fruitSizes[currentFruit] + 5,
    BOX_RIGHT - fruitSizes[currentFruit] - 5
  );

  Fruit f = new Fruit(
    x,
    BOX_TOP + 35,
    currentFruit
  );

  fruits.add(f);

  // 放下音效
  playSound(520, 90);

  // 切換水果
  currentFruit = nextFruit;

  nextFruit = int(random(0, 5));

  dropCooldown = 20;
}


// ============================================
// 遊戲結束畫面
// ============================================

void drawGameOver() {

  // 半透明遮罩
  noStroke();

  fill(70, 45, 55, 175);

  rect(
    BOX_LEFT,
    BOX_TOP,
    BOX_RIGHT - BOX_LEFT,
    BOX_BOTTOM - BOX_TOP,
    20
  );

  // 遊戲結束視窗
  fill(255, 245, 230);

  rect(
    105,
    340,
    430,
    235,
    25
  );

  textAlign(CENTER, CENTER);

  fill(225, 95, 95);

  textSize(36);

  text(
    "GAME OVER!",
    width/2,
    390
  );

  fill(140, 90, 75);

  textSize(21);

  text(
    "水果堆得太高啦！",
    width/2,
    440
  );

  fill(240, 130, 75);

  textSize(24);

  text(
    "最終分數：" + score,
    width/2,
    480
  );

  // 重新開始按鈕
  fill(255, 170, 100);

  rect(
    205,
    510,
    230,
    50,
    18
  );

  fill(255);

  textSize(20);

  text(
    "重新開始",
    width/2,
    535
  );
}


// ============================================
// 重新開始遊戲
// ============================================

void startGame() {

  fruits.clear();

  score = 0;

  gameOver = false;

  dangerFrames = 0;

  collisionCooldown = 0;

  dropCooldown = 0;

  currentFruit = int(random(0, 5));

  nextFruit = int(random(0, 5));

  // 開始音效
  playSound(650, 120);
}


// ============================================
// 滑鼠操作
// ============================================

void mousePressed() {

  if (gameOver) {

    // 判斷重新開始按鈕
    if (mouseX > 205 &&
        mouseX < 435 &&
        mouseY > 510 &&
        mouseY < 560) {

      startGame();
    }

    return;
  }

  if (mouseButton == LEFT) {

    dropFruit();
  }
}


// ============================================
// 音效系統
// Java 內建音效，不需要外部音效檔
// ============================================

void playSound(final int frequency,
               final int duration) {

  Thread soundThread = new Thread(

    new Runnable() {

      public void run() {

        try {

          float sampleRate = 22050;

          AudioFormat format = new AudioFormat(
            sampleRate,
            16,
            1,
            true,
            false
          );

          SourceDataLine line =
            AudioSystem.getSourceDataLine(format);

          line.open(format);

          line.start();

          int samples =
            (int)(sampleRate * duration / 1000);

          byte[] data = new byte[samples * 2];

          for (int i = 0; i < samples; i++) {

            double time = i / sampleRate;

            double envelope =
              1.0 - (double)i / samples;

            double wave =
              Math.sin(
                2.0 * Math.PI * frequency * time
              );

            short value = (short)(
              wave * envelope * 5000
            );

            data[i * 2] =
              (byte)(value & 0xff);

            data[i * 2 + 1] =
              (byte)((value >> 8) & 0xff);
          }

          line.write(
            data,
            0,
            data.length
          );

          line.drain();

          line.stop();

          line.close();

        } catch (Exception e) {

          // 沒有音訊裝置時不影響遊戲執行
        }
      }
    }
  );

  soundThread.setDaemon(true);

  soundThread.start();
}
