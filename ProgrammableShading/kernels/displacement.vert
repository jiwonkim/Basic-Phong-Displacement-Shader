// displacement.vert

/*
 This GLSL vertex shader performs displacement mapping
 using an analytical displacement function.
 */
#define PI 3.141592
#define NUM_OCTAVES 4.
#define PERSISTENCE 0.25

// Defines one wave with variables such as
// amplitude, freqency, speed, and x and y directions
struct wave{
  float A, L, S, x, y;
};

// array of existing waves for lake
uniform wave waves[10];

// magnitude of trampoline bounce
uniform float bounce;

// time
uniform float t;

// boolean variables to determine which mode to display
uniform bool lake, trampoline, ocean;

// This 'varying' vertex output can be read as an input
// by a fragment shader that makes the same declaration.

varying vec2 texPos;
varying vec3 modelPos;
varying vec3 lightSource;
varying vec3 normal;

varying float displacement;

// ----------- Perlin Noise 2D ------------ //

float interpolate(float a, float b, float x) {
  float ft = x*PI;
  float f = (1. - cos(ft))*0.5;
  return a*(1.-f) + b*f;
}

float noise(float i,float x, float y) {
  float p1 = 12.9898;
  float p2 = 78.233;
  return fract(sin(dot(vec2(x,y),vec2(p1,p2)))*43758.5453);
}

float smoothedNoise(float i, float x, float y) {
  float corners, sides, center;
  corners = (noise(i,x-1.,y-1.) + noise(i,x+1.,y-1.) + noise(i,x-1.,y+1.) + noise(i,x+1., y+1.))/16.;
  sides = (noise(i,x-1.,y) + noise(i,x+1.,y) + noise(i,x, y-1.) + noise(i,x, y+1.))/8.;
  center = noise(i,x,y)/4.;
  return corners + sides + center;
}

float interpolatedNoise(float i, float x, float y) {
  int integer_x = int(x);
  float fractional_x = x - float(integer_x);

  int integer_y = int(y);
  float fractional_y = y - float(integer_y);

  float v1, v2, v3, v4;
  v1 = smoothedNoise(i,float(integer_x),float(integer_y));
  v2 = smoothedNoise(i,float(integer_x+1),float(integer_y));
  v3 = smoothedNoise(i,float(integer_x),float(integer_y+1));
  v4 = smoothedNoise(i,float(integer_x+1),float(integer_y+1));

  float i1, i2;
  i1 = interpolate(v1,v2,fractional_x);
  i2 = interpolate(v3,v4,fractional_x);

  return interpolate(i1,i2,fractional_y);
}

float perlinNoise(float x, float y) {
  float total = 0.;
  float p = PERSISTENCE;
  float n = NUM_OCTAVES;

  for(float i=0.; i<n; i+=1.) {
    float frequency = pow(2.,i);
    float amplitude = pow(p,i);
    total += interpolatedNoise(i,x*frequency,y*frequency)*amplitude;
  }
  return total;
}

// --------- Lake Waves --------- //

float lake(float u, float v) {
  float height = 0.;
  for(int i=0; i<10; i++) {
    float A, L, S;
    vec2 D = vec2(waves[i].x,waves[i].y);
    A = waves[i].A;
    L = waves[i].L;
    S = waves[i].S;
    height += A*sin(dot(D,vec2(u,v)*2.0*PI/L) + t*S);
  }

  return height*0.2;
}

// ---- Trampoline Bouncing ---- //

float trampoline(float u, float v) {
  float A,S;
  A = bounce/(t+1.);
  S = pow(t,0.6);
  if(A<0.01) return 0.;
  return A*(sin(u*PI-t*S-PI) + sin(PI*u+t*S+PI) + sin(v*PI-t*S-PI) + sin(PI*v+t*S+PI));
}

/*
 * Height function for displacement
 */
float h(float u, float v) {
  if(lake) return lake(u,v);
  if(ocean) return perlinNoise(10.*u,10.*v);
  if(trampoline) return trampoline(u,v);
  return 0.;
}

void main()
{
    // Tell the fragment shader we have done vertex displacement
    displacement = 1.0;
    
	normal = gl_Normal.xyz;
	modelPos = gl_Vertex.xyz;
    
    // Copy the standard OpenGL texture coordinate to the output.
    texPos = gl_MultiTexCoord0.xy;
    
	/* CS 148 TODO: Modify 'modelPos' and 'normal' using your displacment function */

  float u, v, height;
  u = texPos[0], v = texPos[1];
  height = h(u,v);
  modelPos += height*normal;

  float dhu, dhv, delta;
  delta = 0.001;
  dhu = (h(u+delta,v)-height)/delta;
  dhv = (h(u,v+delta)-height)/delta;

  vec3 t1, t2;
  t1 = normalize(vec3(1.0,dhu,0.0));
  t2 = normalize(vec3(0.0,dhv,-1.0));
  normal = cross(t1, t2);

  /* --------------------------------------------------------------------------- */ 
    // Render the shape using modified position.
    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix *  vec4(modelPos,1);
    
    // we may need this in the fragment shader...
    modelPos = (gl_ModelViewMatrix * vec4(modelPos,1)).xyz;
    
	// send the normal to the shader
	normal = (gl_NormalMatrix * normal);
    
    // push light source through modelview matrix to find its position
    // in model space and pass it to the fragment shader.
    lightSource = gl_LightSource[0].position.xyz;
}
