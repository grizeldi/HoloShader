#import "Common/ShaderLib/GLSLCompat.glsllib"

uniform vec4 m_MainColor;
uniform float g_Time;

#ifdef ISTEXTURED
    uniform sampler2D m_MainTexture;
#endif
#ifdef HASBARS
    uniform float m_BarSpeed;
    uniform float m_BarDistance;
#endif
#ifdef HASALPHA
    uniform float m_Alpha;
#endif
#ifdef SHOULDFLICKER
    uniform float m_FlickerSpeed;
#endif
#ifdef HASRIM
    uniform vec4 m_RimColor;
    uniform float m_RimPower;
#endif
#ifdef HASGLOW
    uniform float m_GlowSpeed;
    uniform float m_GlowDistance;
#endif

in vec3 vertexWorldPos;
in vec3 vertexModelPos;
in vec3 worldNormal;
in vec3 viewDir;
in vec2 texCoord;

//thanks, github
float rand(float n){
    return fract(sin(n) * 43758.5453123);
}

float noise(float p){
    float fl = floor(p);
    float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}

void main(){
    
    //Texture
    vec4 texColor = vec4(1.0);
    #ifdef ISTEXTURED
        texColor = texture2D(m_MainTexture, texCoord);
    #endif

    //Scan effect
    float bars = 0.0;
    #ifdef HASBARS
        float val = g_Time * m_BarSpeed + vertexWorldPos.y * m_BarDistance;
        bars = step(val - floor(val), 0.5) * 0.65;
    #endif

    //Just plain old alpha
    float alpha = 1.0;
    #ifdef HASALPHA
        alpha = m_Alpha;
    #endif

    //Flickering
    float flicker = 1.0;
    #ifdef SHOULDFLICKER
        flicker = clamp(noise(g_Time * m_FlickerSpeed), 0.65, 1.0);
    #endif

    //Rim lighting
    float rim = 1.0;
    vec4 rimColor = vec4(0.0);
    #ifdef HASRIM
        rim = 1.0 - clamp(dot(viewDir, worldNormal), 0.0, 1.0);
        rimColor = m_RimColor * pow(rim, m_RimPower);
    #endif

    //Glow
    float glow = 0.0;
    #ifdef HASGLOW
        float tempGlow = vertexWorldPos.y * m_GlowDistance - g_Time * m_GlowSpeed;
        glow = tempGlow - floor(tempGlow);
    #endif
    
    vec4 color = texColor * m_MainColor + rimColor + (glow * 0.35 * m_MainColor);
    color.a = texColor.a * alpha * (bars + rim + glow) * flicker;
    gl_FragColor = color;
}