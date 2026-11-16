// week11_3_Processing_joystick_serial_available_3_myPort_read
// 要把Arduino的資料,用USB讀入(要記得關 Arduino 的  Serial Monitor)
import processing.serial.*; // 使用USB的Serial的外掛
Serial myPort;
void setup() {
  size(512, 512);
  myPort = new Serial( this, "COM4", 9600);
}
int x = 0, y = 0, sw = 0;
void draw() {
  background(255);
  if (myPort.available() >= 3) { 
    // 亂碼、亂碼、U/D
    x = (int) myPort.read();
    y = (int) myPort.read();
    sw = (int) myPort.read();
    // myPort.read();
  }
  ellipse( x+128, y+128, 8, 8);
}
