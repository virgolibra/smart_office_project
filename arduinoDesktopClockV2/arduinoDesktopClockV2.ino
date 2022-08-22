#include <SPI.h>
#include <MFRC522.h>
#include <Adafruit_NeoPixel.h>
#include <TM1637.h>
#include <Wire.h>
#include <Adafruit_BMP085.h>
#include <ArduinoMqttClient.h>  // MQTT

#include <WiFiNINA.h>
#include <WiFiUdp.h>
#include <RTCZero.h>
#include "arduino_secrets.h"


#define RST_PIN 9
#define SS_PIN 10
#define pixelPin 6
#define TM_CLK 4
#define TM_DIO 5

#define NUMPIXELS 8
#define pixelBrightness 5
#define seaLevelPressure_hPa 1013.25  // Pressure at sea level

// ------------------ Wi-Fi and MQTT connection ----------------------------------------------------
char ssid[] = SECRET_SSID;        // your network SSID
char pass[] = SECRET_PASS;    // your network password
const char* mqttuser = SECRET_MQTTUSER;
const char* mqttpass = SECRET_MQTTPASS;

int keyIndex = 0;                 // your network key Index number (needed only for WEP)
int status = WL_IDLE_STATUS;      //connection status

WiFiClient wifiClient;
MqttClient mqttClient(wifiClient);


const char broker[] = "mqtt.cetools.org";
int        port     = 1884;
const char topic1_temperature[]  = "student/CASA0022/ucfnmz0/nano33/temperature";
const char topic2_tagID[]  = "student/CASA0022/ucfnmz0/nano33/tagID";
const char topic3_pressure[]  = "student/CASA0022/ucfnmz0/nano33/pressure";
const char topic4_altitude[]  = "student/CASA0022/ucfnmz0/nano33/altitude";
const char topic5_tagFlag[]  = "student/CASA0022/ucfnmz0/nano33/tagFlag";
//const char topic5_ppm[]  = "student/CASA0016/project/ucfnmz0/ppm";
//const char topic6_sound[]  = "student/CASA0016/project/ucfnmz0/soundStatus";
//const char topic7_uv[]  = "student/CASA0016/project/ucfnmz0/uvValue";

// -------------------------------------------

const int GMT = 1;
RTCZero rtc_wifi;

// Variable to represent epoch
unsigned long epoch;

// Variable for number of tries to NTP service
int numberOfTries = 0, maxTries = 5;

bool timeFlag = false;


byte set_year = 0; // can only be 2-digit year
byte set_month = 0;
byte set_date = 0;
byte set_hour = 0;
byte set_minute = 0;
byte set_second = 0;
void initRealTime() {
  set_year = rtc_wifi.getYear(); // can only be 2-digit year
  set_month = rtc_wifi.getMonth();
  set_date = rtc_wifi.getDay();
  set_hour = rtc_wifi.getHours();
  set_minute = rtc_wifi.getMinutes();
  set_second = rtc_wifi.getSeconds();
}

byte readCard[4];
//String MasterTag = "20C3935E";  // REPLACE this Tag ID with your Tag ID!!!
String MasterTag = "83464094";  // REPLACE this Tag ID with your Tag ID!!!
String tagID = "";

// Create instances
MFRC522 mfrc522(SS_PIN, RST_PIN);
Adafruit_NeoPixel pixels(NUMPIXELS, pixelPin);
TM1637 tm(TM_CLK, TM_DIO);
Adafruit_BMP085 bmp;

float bmpTemperature = 0;
float bmpPressure = 0; // pressure and altitude (BMP180)
float bmpAltitude = 0;
unsigned int tagFlag = 0;



void setup()
{
  // Initiating
  Serial.begin(9600);   // Initialize serial communications with the PC
//  while (!Serial);

  // ------------- WIFI & MQTT init --------------------


  // attempt to connect to Wifi network:
  Serial.print("Attempting to connect to SSID: ");
  Serial.println(ssid);

  setupPixelDisplay(2);
  while (WiFi.begin(ssid, pass) != WL_CONNECTED) {
    // failed, retry
    Serial.print(".");
    delay(5000);
  }

  Serial.println("You're connected to the network");
  Serial.println();

  setupPixelDisplay(3);
  delay(1000);

  Serial.print("Attempting to connect to the MQTT broker: ");
  Serial.println(broker);

  setupPixelDisplay(4);
  mqttClient.setUsernamePassword(mqttuser, mqttpass);
  if (!mqttClient.connect(broker, port)) {
    Serial.print("MQTT connection failed! Error code = ");
    Serial.println(mqttClient.connectError());

    while (1);
  }

  Serial.println("You're connected to the MQTT broker!");
  Serial.println();

  setupPixelDisplay(5);
  delay(1000);

  //----------------------------------


  SPI.begin(); // SPI bus
  mfrc522.PCD_Init(); // MFRC522
  pixels.begin();
  setScaningPixelDisplay();
  delay(200);


  Serial.println("Scan Your Card>>");
  displayNumber(0000);

  // BMP180 init and check if BMP180 exist
  if (!bmp.begin()) {
    Serial.println("Cannot find BMP180 Module");
    while (1) {}
  }


  // ------------- Time display --------------------
  tm.init();
  tm.set(2);  //set brightness; 0-7

  delay(1000);
  // Start Real Time Clock
  rtc_wifi.begin();


  do {
    epoch = WiFi.getTime();
    Serial.print(WiFi.getTime());
    numberOfTries++;
    Serial.print("tryGetTime");
    delay(200);
  }

  while ((epoch == 0) && (numberOfTries < maxTries));

  if (numberOfTries == maxTries) {
    Serial.print("NTP unreachable!!");
    while (1);
  }

  else {
    Serial.print("Epoch received: ");
    Serial.println(epoch);
    rtc_wifi.setEpoch(epoch + GMT * 60 * 60);
    Serial.println();
  }

  initRealTime();
  Serial.println("Initializing real time done.");
  Serial.println("Online date & time: " + String(set_year) + "-" + String(set_month) + "-" + String(set_date) + " " + String(set_hour) + ":" + String(set_minute) + ":" + String(set_second));



  // -------------- init sensor data update --------
  displayTime();
  getBmpData();
  sendMQTT();

  Serial.println();

  delay(1000);
}

void loop()
{


  mqttClient.poll();


  displayTime();
  getBmpData();
  getID();
  sendMQTT();

  if ((rtc_wifi.getSeconds() > 10) && (timeFlag == false) ) {
    if (getEpochFromWifi()) {
      Serial.println("Time calibration failed");
    } else {
      Serial.println("Time calibrated");
      timeDonePixelDisplay();

    }
    timeFlag = true;
    Serial.println("timeFlag == true");
  }

  if ((rtc_wifi.getSeconds() > 0) && (rtc_wifi.getSeconds() < 10) && (timeFlag == true)) {
    timeFlag = false;

    Serial.println("timeFlag == false");
  }
  delay(2000);


  //
  //  //Wait until new tag is available
  //  while (getID())
  //  {
  //
  //
  //    if (tagID == MasterTag)
  //    {
  //      setGrantedPixelDisplay();
  //      Serial.println(" Access Granted!");
  //      // You can write any code here like opening doors, switching on a relay, lighting up an LED, or anything else you can think of.
  //
  //
  //
  //    }
  //    else
  //    {
  //      setDeniedPixelDisplay();
  //
  //      Serial.println(" Access Denied!");
  //    }
  //
  //    Serial.print(" ID : ");
  //    Serial.println(tagID);
  //
  //    delay(2000);
  //
  //    setScaningPixelDisplay();
  //
  //    Serial.println(" Access Control ");
  //    Serial.println("Scan Your Card>>");
  //  }
}

//Read new tag if available
boolean getID()
{
  tagFlag = 0;
  // Getting ready for Reading PICCs
  if ( ! mfrc522.PICC_IsNewCardPresent()) { //If a new PICC placed to RFID reader continue
    return false;
  }
  if ( ! mfrc522.PICC_ReadCardSerial()) { //Since a PICC placed get Serial and continue
    return false;
  }
  tagID = "";
  for ( uint8_t i = 0; i < 4; i++) { // The MIFARE PICCs that we use have 4 byte UID
    //readCard[i] = mfrc522.uid.uidByte[i];
    tagID.concat(String(mfrc522.uid.uidByte[i], HEX)); // Adds the 4 bytes in a single String variable
  }
  tagID.toUpperCase();
  mfrc522.PICC_HaltA(); // Stop reading
  cardReadPixelDisplay();
  tagFlag = 1;
  return true;
}

void setDeniedPixelDisplay() {
  pixels.clear();
  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.setPixelColor(i, 204, 102, 0); // orange
    pixels.setBrightness(pixelBrightness);
  }
  pixels.show();
}

void setGrantedPixelDisplay() {
  pixels.clear();
  for (int i = 0; i < NUMPIXELS; i++) {
    //    pixels.setPixelColor(i, 150, 0, 0); //red
    pixels.setPixelColor(i, 0, 155, 0); //green
    pixels.setBrightness(pixelBrightness);
  }

  pixels.show();
}

void setScaningPixelDisplay() {
  pixels.clear();
  for (int i = 0; i < NUMPIXELS; i++) {
    //    pixels.setPixelColor(i, 150, 0, 0); //red
    pixels.setPixelColor(i, 0, 0, 155); //blue
    pixels.setBrightness(pixelBrightness);
  }

  pixels.show();
}

void setupPixelDisplay(int numberOfPixelOn) {
  pixels.clear();
  for (int i = 0; i < numberOfPixelOn; i++) {
    pixels.setPixelColor(i, 150, 0, 0); // red
    pixels.setBrightness(pixelBrightness);
  }
  pixels.show();
}

void mqttUploadPixelDisplay() {
  //  for (int i = 0; i < NUMPIXELS; i++) {
  //    pixels.clear();
  //    pixels.setPixelColor(i, 0, 102, 204); // blue
  //    pixels.setBrightness(pixelBrightness);
  //    pixels.show();
  //    delay(50);
  //  }
  //
  //  pixels.clear();
  //  pixels.show();
  //  delay(100);
  //
  //  for (int i = 0; i < NUMPIXELS; i++) {
  //    pixels.setPixelColor(i, 0, 102, 204); // blue
  //    pixels.setBrightness(pixelBrightness);
  //  }
  //  pixels.show();

  pixels.clear();
  for (int i = 0; i < 8; i++) {
    pixels.setPixelColor(i, 150, 0, 0); // red
    pixels.setBrightness(pixelBrightness);
  }
  pixels.show();

}

void timeDonePixelDisplay() {
  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.clear();
    pixels.setPixelColor(i, 153, 102, 204); // purple
    pixels.setBrightness(pixelBrightness);
    pixels.show();
    delay(50);
  }

  pixels.clear();
  pixels.show();
  delay(100);

  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.setPixelColor(i, 153, 102, 204); // purple
    pixels.setBrightness(pixelBrightness);
  }
  pixels.show();



}


void cardReadPixelDisplay() {
  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.clear();
    pixels.setPixelColor(i, 0, 140, 20); // green
    pixels.setBrightness(pixelBrightness);
    pixels.show();
    delay(50);
  }

  pixels.clear();
  pixels.show();
  delay(100);

  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.setPixelColor(i, 0, 140, 20); // blue
    pixels.setBrightness(pixelBrightness);
  }
  pixels.show();

  delay(1000);


}

void displayNumber(int num) {
  tm.display(3, num % 10);
  tm.display(2, num / 10 % 10);
  tm.display(1, num / 100 % 10);
  tm.display(0, num / 1000 % 10);
}


void displayTime() {

  // display hour
  int numHour = rtc_wifi.getHours();
  tm.display(1, numHour % 10);
  tm.display(0, numHour / 10 % 10);

  // display minute
  int numMinute = rtc_wifi.getMinutes();
  tm.display(3, numMinute % 10);
  tm.display(2, numMinute / 10 % 10);

  tm.point(1);

}

void getBmpData() {
  bmpTemperature = bmp.readTemperature();
  bmpPressure = bmp.readSealevelPressure() * 0.01;
  bmpAltitude = bmp.readAltitude(seaLevelPressure_hPa * 100);

  Serial.print(">>> BMP Update |");
  Serial.print("Temperature: ");
  Serial.print(bmpTemperature);
  Serial.print(" *C");
  Serial.print(" | Pressure: ");
  Serial.print(bmpPressure);
  Serial.print(" hPa");
  Serial.print(" | Real altitude: ");
  Serial.print(bmpAltitude);
  Serial.println(" meters");

}
// ------------------------------------------------------------------------------------
//                                    send MQTT
// ------------------------------------------------------------------------------------
void sendMQTT() {



  // call poll() regularly to allow the library to send MQTT keep alive which
  // avoids being disconnected by the broker
  mqttClient.poll();

  if (mqttClient.connected()) {
    // send message, the Print interface can be used to set the message contents
    mqttClient.beginMessage(topic1_temperature);
    mqttClient.print(bmpTemperature);
    mqttClient.endMessage();

    mqttClient.beginMessage(topic2_tagID);
    mqttClient.print(tagID);
    mqttClient.endMessage();

    mqttClient.beginMessage(topic3_pressure);
    mqttClient.print(bmpPressure);
    mqttClient.endMessage();

    mqttClient.beginMessage(topic4_altitude);
    mqttClient.print(bmpAltitude);
    mqttClient.endMessage();

    mqttClient.beginMessage(topic5_tagFlag);
    mqttClient.print(tagFlag);
    mqttClient.endMessage();

    //    mqttClient.beginMessage(topic5_ppm);
    //    mqttClient.print(mqPPM);
    //    mqttClient.endMessage();
    //
    //    mqttClient.beginMessage(topic6_sound);
    //    mqttClient.print(soundDetectorStatus);
    //    mqttClient.endMessage();
    //
    //    mqttClient.beginMessage(topic7_uv);
    //    mqttClient.print(uvValue);
    //    mqttClient.endMessage();

    Serial.println("Sending messages to MQTT done!");
    Serial.println();

    mqttUploadPixelDisplay();
  }

  else { // if the client has been disconnected,
    Serial.println("Client disconnected, attempting reconnection");
    Serial.println();


    if (!attemptReconnect()) { // try reconnecting
      Serial.print("Client reconnected!");
      Serial.println();

    }

  }

}


int attemptReconnect() {
  if (!mqttClient.connect(broker, port)) {
    Serial.print("MQTT connection failed! Error code = ");
    Serial.println(mqttClient.connectError());

  }
  return mqttClient.connectError(); // return status
}


int getEpochFromWifi() {
  // Get epoch
  do {
    epoch = WiFi.getTime();
    Serial.print(WiFi.getTime());
    numberOfTries++;
    Serial.print("tryGetTime");
    delay(200);
  }

  while ((epoch == 0) && (numberOfTries < maxTries));

  if (numberOfTries == maxTries) {
    Serial.print("NTP unreachable!!");
    return 1;
  }

  else {
    Serial.print("Epoch received: ");
    Serial.println(epoch);
    rtc_wifi.setEpoch(epoch + GMT * 60 * 60);
    Serial.println();
  }

  initRealTime();
  Serial.println("Initializing real time done.");
  Serial.println("Online date & time: " + String(set_year) + "-" + String(set_month) + "-" + String(set_date) + " " + String(set_hour) + ":" + String(set_minute) + ":" + String(set_second));
  return 0;



}
