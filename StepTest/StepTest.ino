static const int Pin_EN_1 = 33;
static const int Pin_EN_2 = 40;
static const int Pin_M0_1 = 37;
static const int Pin_M0_2 = 41;
static const int Pin_M1_1 = 36;
static const int Pin_M1_2 = 13;
static const int Pin_M2_1 = 35;
static const int Pin_M2_2 = 14;
static const int Pin_STP_1 = 38;
static const int Pin_STP_2 = 15;
static const int Pin_DIR1 = 39;
static const int Pin_DIR2 = 16;
static const int Pin_RA_plus = 6;
static const int Pin_RA_minus = 3;
static const int Pin_DE_plus = 5;
static const int Pin_DE_minus = 4;

void setup()
{
    digitalWrite(Pin_M0_1, LOW);
    digitalWrite(Pin_M1_1, LOW);
    digitalWrite(Pin_M2_1, LOW);
    digitalWrite(Pin_STP_1, LOW);
    digitalWrite(Pin_DIR1, LOW);
    pinMode(Pin_EN_1, OUTPUT);
    pinMode(Pin_M0_1, OUTPUT);
    pinMode(Pin_M1_1, OUTPUT);
    pinMode(Pin_M2_1, OUTPUT);
    pinMode(Pin_STP_1, OUTPUT);
    pinMode(Pin_DIR1, OUTPUT);

    digitalWrite(Pin_M0_2, LOW);
    digitalWrite(Pin_M1_2, LOW);
    digitalWrite(Pin_M2_2, LOW);
    digitalWrite(Pin_STP_2, LOW);
    digitalWrite(Pin_DIR2, LOW);
    pinMode(Pin_EN_2, OUTPUT);
    pinMode(Pin_M0_2, OUTPUT);
    pinMode(Pin_M1_2, OUTPUT);
    pinMode(Pin_M2_2, OUTPUT);
    pinMode(Pin_STP_2, OUTPUT);
    pinMode(Pin_DIR2, OUTPUT);

    digitalWrite(Pin_EN_1, HIGH);
    digitalWrite(Pin_EN_2, HIGH);

    pinMode(Pin_RA_plus, INPUT);
    pinMode(Pin_RA_minus, INPUT);
    pinMode(Pin_DE_plus, INPUT);
    pinMode(Pin_DE_minus, INPUT);

   pinMode(LED_BUILTIN, OUTPUT);
   digitalWrite(LED_BUILTIN, LOW);
   Serial.begin(9600);
   Serial.write("Testing LV8729 and ST4\r\n");
}

uint8_t st4Read(uint8_t v, int pin)
{
    v <<= 1;
    if (digitalRead(pin) == HIGH)
        v |= 1;
    return v;
}

void loop()
{
    auto now = millis();
    static auto lasttime = now;
    static bool flash = true;
    static uint8_t prev_ST4_Pins = 0xFF;
    static bool Use_ST4 = false;

    if (flash && (now - lasttime > 1000))
    {
        lasttime = now;
        digitalWrite(LED_BUILTIN, digitalRead(LED_BUILTIN) == LOW ? HIGH : LOW);
    }

    uint8_t ST4_pins = 0;
    enum class ST4 {NONE, DE_minus = 1, DE_plus = 2, RA_minus = 4, RA_plus = 8};
    ST4_pins = st4Read(ST4_pins, Pin_RA_plus);
    ST4_pins = st4Read(ST4_pins, Pin_RA_minus);
    ST4_pins = st4Read(ST4_pins, Pin_DE_plus);
    ST4_pins = st4Read(ST4_pins, Pin_DE_minus);

    auto stat = (uint8_t)(0xfu & ~ST4_pins);

    if (ST4_pins != prev_ST4_Pins)
    {
        Serial.write("ST4 change 0x");
        Serial.println(stat, HEX);
        prev_ST4_Pins = ST4_pins;
    }

    if (stat & static_cast<unsigned>(ST4::DE_plus))
        digitalWrite(Pin_DIR1, HIGH);
    else if (stat & static_cast<unsigned>(ST4::DE_minus))
        digitalWrite(Pin_DIR1, LOW);

    if (stat & (static_cast<unsigned>(ST4::DE_plus) | static_cast<unsigned>(ST4::DE_minus)))
    {
        auto prev = digitalRead(Pin_STP_1) == HIGH;
        digitalWrite(Pin_STP_1, prev ? LOW : HIGH);
        delayMicroseconds(700);
    }

    if (stat & static_cast<unsigned>(ST4::RA_plus))
        digitalWrite(Pin_DIR2, HIGH);
    else if (stat & static_cast<unsigned>(ST4::RA_minus))
        digitalWrite(Pin_DIR2, LOW);

    if (stat & (static_cast<unsigned>(ST4::RA_plus) | static_cast<unsigned>(ST4::RA_minus)))
    {
        auto prev = digitalRead(Pin_STP_2) == HIGH;
        digitalWrite(Pin_STP_2, prev ? LOW : HIGH);
        delayMicroseconds(700);
    }


    while (Serial.available() > 0)
    {
        auto c = Serial.read();
        if (c == 'S')
        {
             bool prev = false;
             Serial.write("start\r\n");
             int turns = 400;
             for (int i = 0; i < turns *5; i++)
             {
                digitalWrite(Pin_STP_1, prev ? HIGH : LOW);   
                delayMicroseconds(700);
                prev = !prev;  
             }        
             Serial.write("done\r\n");
 
        } 
        else if (c == 'U')
        {
            bool prev = digitalRead(Pin_EN_1) == LOW;
            digitalWrite(Pin_EN_1, prev ? HIGH : LOW);
            digitalWrite(Pin_EN_2, prev ? HIGH : LOW);
            Serial.write("Enable is now ");
            Serial.write(prev ? "off\r\n" : "on\r\n" );
        }
        else if (c == 'F')
        {
            flash = !flash;
            digitalWrite(LED_BUILTIN, flash ? HIGH : LOW);
        }
        else if (c == 'D')
        {
            bool prev = digitalRead(Pin_DIR1) == LOW;
            digitalWrite(Pin_DIR1, prev ? HIGH : LOW);
            Serial.write("Dir is ");
            Serial.write(prev ? "high\r\n" : "low\r\n");
        }
        else if (c == '4')
            Use_ST4 = !Use_ST4;
    }

}