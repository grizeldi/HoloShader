#import "Common/ShaderLib/GLSLCompat.glsllib"
#import "Common/ShaderLib/Skinning.glsllib"

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

in vec3 inPosition;
in vec3 inNormal;
in vec2 inTexCoord;

out vec3 vertexWorldPos;
out vec3 vertexModelPos;
out vec3 worldNormal;
out vec3 viewDir;
out vec2 texCoord;

void main(){
    vec4 modelSpacePos = vec4(inPosition, 1.0);
    vec3 modelSpaceNorm = inNormal;
    #ifdef NUM_BONES
        Skinning_Compute(modelSpacePos, modelSpaceNorm);
    #endif
    
    vertexWorldPos = (g_WorldMatrix * modelSpacePos).xyz;
    vertexModelPos = modelSpacePos.xyz;
    texCoord = inTexCoord;
    worldNormal = normalize(g_NormalMatrix * modelSpaceNorm);
    viewDir = normalize(-(g_WorldViewMatrix * modelSpacePos).xyz);

    vec3 outPosition = (g_WorldMatrix * modelSpacePos).xyz;
    
    //Glitch
    #ifdef SHOULDGLITCH
        outPosition.x += m_GlitchIntensity * step(0.5, sin(g_Time * 2.0 + inPosition.y * 1.0)) * step(0.99, sin(g_Time * m_GlitchSpeed * 0.5));
    #endif
    
    gl_Position = g_WorldViewProjectionMatrix * modelSpacePos;
}