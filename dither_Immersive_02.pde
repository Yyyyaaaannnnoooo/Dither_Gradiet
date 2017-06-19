int level = 1;
float num = 0, fac = 16, count = 0;
color col1 = color(0, 255, 255), col2 = color(255, 0, 255), nCol1, nCol2;
String hex1 = hex(col1);
String hex2 = hex(col2);
PImage dit;
void setup() {
  size(900, 600);
  background(0);
  //noStroke();
  //fac = random(16);
  dit = createImage(300, 300, RGB);

  dit = gradient(dit, col1, col2);
  dit = dither(dit, fac, level);
  //dit = gradient(dit, col1, col2);
  //PImage dithered = dither(dit, fac, level);
  //image(dithered, 0, 0);
  //hex1 = hex(col1);
  //hex2 = hex(col2);
  //String txt = "Pretty Dither #"+hex1+" to #"+hex2+" dither factor: "+fac+" color level: "+level;
  //text(txt, 10, 815);
  //saveFrame("output.png");
}
void draw() {
  //fac = random(16);

  if (frameCount % 2== 0)genDither(count);
  image(dit, 0, 0);
  hex1 = hex(col1);
  hex2 = hex(col2);
  String txt = "Dither from #"+hex1+" to #"+hex2+" dither factor: "+fac+" color level: "+level;
  surface.setTitle(txt);
  count += 0.05;
  PImage big = nearestNeighbour(dit);
  image(big, 300, 0);
  println(frameRate);
}
void keyPressed() {
  if (key == CODED) {
    if (keyCode ==  UP) fac += 0.1;
    if (keyCode ==  DOWN) fac -= 0.1;
    if(keyCode ==  RIGHT) level += 1;
    if(keyCode ==  LEFT) level -= 1;
  }
}
void genDither(float value) {
  colorMode(HSB);
  col1 = color(value % 255, 255, 255);
  float val2 = value + 155.0;
  col2 = color(val2 % 255, 255, 255);
  colorMode(RGB);
  dit = gradient(dit, col1, col2);
  image(dit, 0, 300);
  //fac = map(mouseX, 0, width / 2, -10.0, 16.0);
  //level = int(map(mouseY, height, 0, -10, 20));
  dit = dither(dit, fac, level);
}
PImage dither(PImage src1, float factor, int lev) {
  int s = 1;
  //println(factor);
  ///create a copy of the original image///
  PImage src = createImage(src1.width, src1.height, RGB);
  arrayCopy(src1.pixels, src.pixels);
  src.loadPixels();
  for (int x = 1; x < src.width - 1; x += s) {
    for (int y = 1; y < src.height - 1; y += s) {
      int index = x + y * src.width;
      color oldpixel = src.pixels[index];
      color newpixel = findClosestColor(oldpixel, lev); //con 8 pixel sorting
      src.pixels[index] = newpixel;
      color quant_error = subColor(oldpixel, newpixel);

      //Floyd Steinberg
      color s1 = src.pixels[(x + s) + ( y * src.width)];
      src.pixels[(x + s)+ ( y * src.width)] = quantizedColor(s1, quant_error, 7.0 / factor);
      color s2 = src.pixels[(x - s)+ ( (y + s)     * src.width)];
      src.pixels[(x - s)+ ( (y + s) * src.width)] = quantizedColor(s2, quant_error, 3.0 / factor);
      color s3 = src.pixels[x + ( (y + s) * src.width)];
      src.pixels[x + ( (y + s) * src.width)] = quantizedColor(s3, quant_error, 5.0/factor);
      color s4 = src.pixels[(x + s)+ ((y + s ) * src.width)];
      src.pixels[(x + s)+ ((y + s ) * src.width)] = quantizedColor(s4, quant_error, 1.0/factor);
    }
  }
  src.updatePixels();
  return src;
}

/// find the nearest color, lev defines the number ///
/// of colors the image will be divided,           /// 
/// with 1 meaning 8 colors (RGB + CMYK + WHITE)   ///

color findClosestColor(color in, int lev) {

  float r = (in >> 16) & 0xFF;
  float g = (in >> 8) & 0xFF;
  float b = in & 0xFF;
  ///Normalizing the colors///
  //level = lev;
  float norm = 255.0 / lev;
  float nR = round((r / 255) * lev) * norm;
  float nG = round((g / 255) * lev) * norm;
  float nB = round((b / 255) * lev) * norm;
  color newPix = color (nR, nG, nB);
  return newPix;
}


/////subtracting two different colors (a - b)////
color subColor (color a, color b) {

  float r1 = (a >> 16) & 0xFF;
  float g1 = (a >> 8) & 0xFF;
  float b1 = a & 0xFF;

  float r2 = (b >> 16) & 0xFF;
  float g2 = (b >> 8) & 0xFF;
  float b2 = b & 0xFF;

  float r3 = r1 - r2;
  float g3 = g1 - g2;
  float b3 = b1 - b2;

  color c = color(r3, g3, b3);
  return c;
}

/////returns the result between the original color and the quantization error////
color quantizedColor(color c1, color c2, float mult ) {

  float r1 = (c1 >> 16) & 0xFF;
  float g1 = (c1>> 8) & 0xFF;
  float b1 = c1 & 0xFF;

  float r2 = (c2 >> 16) & 0xFF;
  float g2 = (c2>> 8) & 0xFF;
  float b2 = c2 & 0xFF;

  float nR = r1 + mult * r2;
  float nG = g1 + mult * g2;
  float nB = b1 + mult * b2;

  color c3 = color (nR, nG, nB);
  return c3;
}

PImage gradient(PImage img, color c1, color c2) {
  //color c1 = color(random(255), random(255), random(255));
  //color c2 = color(random(255), random(255), random(255));
  img.loadPixels();
  for (int y = 0; y < img.width; y++) {
    for (int x = 0; x < img.height; x++) {
      int index = x + y * img.width;
      float amp = map(index, 0, img.width * dit.height, 0, 1);
      color col = lerpColor(c1, c2, amp);
      img.pixels[index] = col;
    }
  }
  img.updatePixels();
  return img;
}

PImage nearestNeighbour(PImage img) {
  int scaleFactor = 2;
  PImage destination = createImage(img.width * scaleFactor, img.height * scaleFactor, RGB);
  destination.loadPixels();
  for ( int y = 0; y < img.height; y++) {
    for ( int x = 0; x < img.width; x++) {
      int i = x + img.width * y;
      int nX = x * scaleFactor;
      int nY = y * scaleFactor;
      //int destIndex = i * scaleFactor
      destination.pixels[(nX        + destination.width *       nY)] = img.pixels[i];
      destination.pixels[((nX + 1)  + destination.width *       nY)] = img.pixels[i];
      destination.pixels[ (nX       + destination.width * (nY + 1))] = img.pixels[i];
      destination.pixels[((nX + 1)  + destination.width * (nY + 1))] = img.pixels[i];
    }
  }
  destination.updatePixels();
  return destination;
}