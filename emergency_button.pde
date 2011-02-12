const int BUTTON_PIN = 12;
const int LED_PIN = 13;
const int DEBOUNCE = 50;
int button_state = HIGH;
int button_oldstate = HIGH;
long button_statechange = millis();
long last_poll = millis();
long last_press;

// Internal Pullup
// Button goes LOW when pressed

void setup() {
  Serial.begin(57600);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT);
  digitalWrite(BUTTON_PIN, HIGH);
  Serial.println("Emergency button poller is ready.");
}

void loop() {
  long now = millis();
  
  // Debounce input
  int value = digitalRead(BUTTON_PIN);
  if (value !=  button_oldstate){
    button_statechange = now;
  }
  if (now - button_statechange > DEBOUNCE){
    button_state = value;
  }
  button_oldstate = value;    
  
  // Save when we've seen the button pressed for the last time
  if (button_state == LOW){
    last_press = now;
    // LED signals that we have a pressed event pending
    digitalWrite(LED_PIN, HIGH);
  }
  
  // Test whether serial ports wants an update
  int want = 0;
  while (Serial.available() > 0){
    // We don't care what's arriving. Drain all input.
    want++;
    Serial.read();
  }
  if (want > 0){
    Serial.print("now=");
    Serial.print(now);
    Serial.print(" previous=");
    Serial.print(last_poll);
    Serial.print(" pressed=");

    // If the button was pressed since we were polled last, say so
    if (last_press > last_poll){
      Serial.println("true");     
    }else{
      Serial.println("false");
    }
    want = 0;
    
    // Poll done. Reset last poll time and turn off LED.
    last_poll = now;
    digitalWrite(LED_PIN, LOW);
  }
}

/*
Copyright (c) 2011, Martin Schmitt < mas at scsy dot de >

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/
