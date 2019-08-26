#import "Common/ShaderLib/GLSLCompat.glsllib"

uniform mat4 g_WorldViewProjectionMatrix;
uniform mat4 g_WorldMatrix;
uniform mat4 g_WorldViewMatrix;
uniform mat4 g_ViewProjectionMatrix;
uniform mat3 g_NormalMatrix;
uniform float g_Time;

#ifdef SHOULDGLITCH
    uniform float m_GlitchSpeed;
    uniform float m_GlitchIntensity;
#endif

attribute vec3 inPosition;
attribute vec3 inNormal;
attribute vec2 inTexCoord;

out vec3 vertexWorldPos;
out vec3 vertexModelPos;
out vec3 worldNormal;
out vec3 viewDir;
out vec2 texCoord;

void main(){
    vertexWorldPos = (g_WorldMatrix * vec4(inPosition, 1.0)).xyz;
    vertexModelPos = inPosition;
    texCoord = inTexCoord;
    worldNormal = normalize(g_NormalMatrix * inNormal);
    viewDir = normalize(-(g_WorldViewMatrix * vec4(inPosition, 1.0)).xyz);

    vec3 outPosition = (g_WorldMatrix * vec4(inPosition, 1.0)).xyz;
    //Glitch
    #ifdef SHOULDGLITCH
        outPosition.x += m_GlitchIntensity * step(0.5, sin(g_Time * 2.0 + inPosition.y * 1.0)) * step(0.99, sin(g_Time * m_GlitchSpeed * 0.5));
    #endif
    
    gl_Position = g_ViewProjectionMatrix * vec4(outPosition, 1.0);
}
