void startHX711()
{
  
  scale.begin(DOUT, CLK);
  Serial.print("Scale: ");
  config.offset = scale.read_average();
  Serial.print("Zero Offset: ");
  Serial.print(config.offset);
  Serial.println("");
  Serial.print("Scale: ");
  Serial.print(config.scale, 8);
  Serial.println("");
}
