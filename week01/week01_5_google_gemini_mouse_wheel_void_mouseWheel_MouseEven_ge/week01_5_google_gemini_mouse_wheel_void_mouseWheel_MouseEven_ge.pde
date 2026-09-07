// week01_5_google_gemini_mouse_wheel_void_mouseWheel_MouseEven_getCount
// google gemini: Processing怎麼用到 mouse wheel
// 把AI摘要的程式碼copy過來用
float circleSize = 50; // 宣告全域變數控制大小

void setup() {
  size(400, 400);
}

void draw() {
  background(220);
  // 畫出依滾輪大小變化的圓
  ellipse(width / 2, height / 2, circleSize, circleSize);
}
void mouseWheel(MouseEvent event) {
  // 取得滾輪滾動的值
  float e = event.getCount();
  
  // 根據滾動方向改變數值（向下滾動放大，向上滾動縮小）
  circleSize -= e * 5; 
  
  // 限制圓形大小的最小值與最大值
  circleSize = constrain(circleSize, 10, 350);
}
