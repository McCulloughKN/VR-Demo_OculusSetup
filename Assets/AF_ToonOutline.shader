// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon/Outline"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_AmbientColor("Ambient Color", Color) = (0.1037736,0.1037736,0.1037736,1)
		_LightBlend("Light Blend", Float) = 1
		_Glossiness("Glossiness", Float) = 10
		_SpecularIntensity("Specular Intensity", Range( 0 , 1)) = 1
		_RimThreshold("Rim Threshold", Float) = 5
		_RimBlend("Rim Blend", Range( 0.01 , 1)) = 1
		_RimIntensity("Rim Intensity", Range( 0 , 1)) = 0.75
		_BounceThreshold("Bounce Threshold", Float) = 5
		_BounceBlend("Bounce Blend", Range( 0.01 , 1)) = 1
		_BounceIntensity("Bounce Intensity", Range( 0 , 1)) = 0.75
		[Toggle]_ShowOutline("Show Outline", Float) = 0
		_OutlineColor("Outline Color", Color) = (0,0.9330416,1,1)
		_OutlineWidth("Outline Width", Float) = 0.025
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = (( _ShowOutline )?( _OutlineWidth ):( 0.0 ));
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _OutlineColor.rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _RimBlend;
		uniform float _RimThreshold;
		uniform float _RimIntensity;
		uniform float _BounceBlend;
		uniform float _BounceThreshold;
		uniform float _BounceIntensity;
		uniform float _LightBlend;
		uniform float _Glossiness;
		uniform float _SpecularIntensity;
		uniform float4 _AmbientColor;
		uniform float4 _MainColor;
		uniform float4 _OutlineColor;
		uniform float _ShowOutline;
		uniform float _OutlineWidth;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 _Outline268 = 0;
			v.vertex.xyz += _Outline268;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float dotResult7 = dot( ase_normWorldNormal , _WorldSpaceLightPos0.xyz );
			float NdotL8 = dotResult7;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult50 = dot( ase_worldViewDir , ase_normWorldNormal );
			float RimDot52 = ( 1.0 - dotResult50 );
			float smoothstepResult69 = smoothstep( 0.0 , _RimBlend , saturate( pow( ( saturate( NdotL8 ) * RimDot52 ) , _RimThreshold ) ));
			float RimCalc180 = ( smoothstepResult69 * _RimIntensity );
			float clampResult254 = clamp( _BounceThreshold , 0.01 , 50.0 );
			float smoothstepResult104 = smoothstep( 0.0 , _BounceBlend , pow( ( RimDot52 * saturate( -NdotL8 ) ) , clampResult254 ));
			float BounceCalc179 = ( smoothstepResult104 * _BounceIntensity );
			float3 normalizeResult34 = normalize( ( ase_worldViewDir + _WorldSpaceLightPos0.xyz ) );
			float dotResult38 = dot( ase_normWorldNormal , normalizeResult34 );
			float clampResult248 = clamp( _LightBlend , 0.01 , 1.0 );
			float smoothstepResult26 = smoothstep( 0.0 , clampResult248 , saturate( dotResult7 ));
			float LightIntensity20 = smoothstepResult26;
			float smoothstepResult46 = smoothstep( 0.005 , 0.01 , pow( ( dotResult38 * LightIntensity20 ) , ( _Glossiness * _Glossiness ) ));
			float SpecularCalc187 = ( smoothstepResult46 * _SpecularIntensity );
			float4 temp_cast_0 = ((0.5 + (( RimCalc180 + BounceCalc179 + SpecularCalc187 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0))).xxxx;
			float4 blendOpSrc243 = temp_cast_0;
			float4 blendOpDest243 = ( ( smoothstepResult26 + _AmbientColor ) * _MainColor );
			float4 _Lighting203 = ( ase_lightColor * ( saturate( (( blendOpDest243 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest243 ) * ( 1.0 - blendOpSrc243 ) ) : ( 2.0 * blendOpDest243 * blendOpSrc243 ) ) )) );
			c.rgb = _Lighting203.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
-1883.333;56.66667;1876.667;946.3334;3220.755;1699.271;1.701227;True;False
Node;AmplifyShaderEditor.CommentaryNode;251;-3572.865,-2383.519;Inherit;False;2416.996;823.2207;Comment;22;5;6;7;8;12;213;9;214;22;243;23;203;244;241;26;248;14;20;11;190;189;250;Cuustom Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;212;-1109.814,-2122.012;Inherit;False;1843.44;559.2407;Comment;18;187;249;47;46;42;43;40;31;52;41;38;34;33;233;51;50;36;32;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;6;-3522.865,-2060.636;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldNormalVector;5;-3469.326,-2215.66;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;32;-990.3674,-2072.012;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;36;-652.0946,-1964.462;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;50;-426.0747,-2065.115;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-3222.884,-1940.433;Inherit;False;Property;_LightBlend;Light Blend;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;7;-3181.4,-2135.48;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;210;-1122.86,-1438.403;Inherit;False;1539.146;461.144;Comment;13;179;256;104;105;106;103;102;254;90;81;100;253;77;Bounce Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-3030.801,-2158.694;Inherit;False;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;233;-1051.311,-1754.381;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ClampOpNode;248;-3024.749,-1937.16;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;51;-262.1816,-2065.008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;12;-3015.78,-2022.439;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;211;-2993.609,-1440.921;Inherit;False;1824.948;566.921;Comment;12;63;101;66;54;70;74;65;67;69;180;258;259;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;26;-2848.885,-2002.933;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-1086.381,-1287.35;Inherit;False;8;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-772.1886,-1775.609;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-81.04762,-2069.806;Inherit;False;RimDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-2943.609,-1368.197;Inherit;False;8;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-2593.452,-2010.721;Inherit;False;LightIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;34;-618.2126,-1775.417;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-2814.185,-1293.161;Inherit;False;52;RimDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;101;-2769.423,-1366.892;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;253;-919.6675,-1285.632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;100;-788.6561,-1287.943;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-815.8467,-1388.402;Inherit;False;52;RimDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-848.2833,-1201.608;Inherit;False;Property;_BounceThreshold;Bounce Threshold;8;0;Create;True;0;0;0;False;0;False;5;1.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-428.1025,-1788.51;Inherit;False;20;LightIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;38;-424.0347,-1888.323;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2620.324,-1270.081;Inherit;False;Property;_RimThreshold;Rim Threshold;5;0;Create;True;0;0;0;False;0;False;5;1.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2620.817,-1369.538;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-386.8284,-1710.351;Inherit;False;Property;_Glossiness;Glossiness;3;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-202.3902,-1887.967;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;254;-599.7844,-1229.208;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-592.9992,-1325.806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-205.3599,-1719.768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;65;-2433.384,-1354.15;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-454.5596,-1185.891;Inherit;False;Property;_BounceBlend;Bounce Blend;9;0;Create;True;0;0;0;False;0;False;1;0.505;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2383.771,-1246.234;Inherit;False;Property;_RimBlend;Rim Blend;6;0;Create;True;0;0;0;False;0;False;1;1;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;258;-2245.284,-1352.468;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;42;-41.85158,-1803.228;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;103;-442.9666,-1323.472;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2134.175,-1122.181;Inherit;False;Property;_RimIntensity;Rim Intensity;7;0;Create;True;0;0;0;False;0;False;0.75;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-396.9585,-1103.682;Inherit;False;Property;_BounceIntensity;Bounce Intensity;10;0;Create;True;0;0;0;False;0;False;0.75;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;249;35.3513,-1671.308;Inherit;False;Property;_SpecularIntensity;Specular Intensity;4;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;104;-167.8388,-1322.273;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;69;-2091.683,-1351.603;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;46;140.7353,-1799.71;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.005;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-1853.284,-1233.468;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;29.03145,-1201.531;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;328.2534,-1740.293;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;494.4995,-1753.626;Inherit;False;SpecularCalc;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;180;-1713.93,-1238.921;Inherit;True;RimCalc;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;179;189.2745,-1204.921;Inherit;False;BounceCalc;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-2585.062,-2186.663;Inherit;False;179;BounceCalc;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-2575.566,-2273.718;Inherit;False;180;RimCalc;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-2825.158,-1778.299;Inherit;False;Property;_AmbientColor;Ambient Color;1;0;Create;True;0;0;0;False;0;False;0.1037736,0.1037736,0.1037736,1;0.8962264,0.3163152,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;250;-2588.366,-2100.813;Inherit;False;187;SpecularCalc;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;213;-2591.784,-1919.964;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;267;-2072.008,-804.0035;Inherit;False;896.5135;426.1241;Comment;6;114;260;266;265;262;268;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;9;-2553.349,-1812.242;Inherit;False;Property;_MainColor;Main Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.990566,0.6189287,0.2289516,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;241;-2374.864,-2203.67;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;244;-2223.291,-2204.524;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;262;-2022.008,-509.8799;Inherit;False;Property;_OutlineWidth;Outline Width;13;0;Create;True;0;0;0;False;0;False;0.025;0.025;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;-2309.458,-1917.262;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-2000.057,-591.1405;Inherit;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;22;-1857.394,-2074.89;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.BlendOpsNode;243;-1950.483,-1940.65;Inherit;True;Overlay;True;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;114;-1843.28,-754.0035;Inherit;False;Property;_OutlineColor;Outline Color;12;0;Create;True;0;0;0;False;0;False;0,0.9330416,1,1;0,0.7899308,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;266;-1835.057,-574.1405;Inherit;False;Property;_ShowOutline;Show Outline;11;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1639.421,-1987.87;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;260;-1589.828,-604.3048;Inherit;False;0;True;None;0;0;Front;True;True;True;True;0;False;-1;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;268;-1395.381,-603.829;Inherit;False;_Outline;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-1407.512,-1975.018;Inherit;False;_Lighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;269;-820.5409,-516.0593;Inherit;False;268;_Outline;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-825.9447,-600.4139;Inherit;False;203;_Lighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;240;-592.0327,-765.666;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Toon/Outline;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;50;0;32;0
WireConnection;50;1;36;0
WireConnection;7;0;5;0
WireConnection;7;1;6;1
WireConnection;8;0;7;0
WireConnection;248;0;14;0
WireConnection;51;0;50;0
WireConnection;12;0;7;0
WireConnection;26;0;12;0
WireConnection;26;2;248;0
WireConnection;33;0;32;0
WireConnection;33;1;233;1
WireConnection;52;0;51;0
WireConnection;20;0;26;0
WireConnection;34;0;33;0
WireConnection;101;0;63;0
WireConnection;253;0;77;0
WireConnection;100;0;253;0
WireConnection;38;0;36;0
WireConnection;38;1;34;0
WireConnection;67;0;101;0
WireConnection;67;1;54;0
WireConnection;40;0;38;0
WireConnection;40;1;41;0
WireConnection;254;0;81;0
WireConnection;102;0;90;0
WireConnection;102;1;100;0
WireConnection;43;0;31;0
WireConnection;43;1;31;0
WireConnection;65;0;67;0
WireConnection;65;1;66;0
WireConnection;258;0;65;0
WireConnection;42;0;40;0
WireConnection;42;1;43;0
WireConnection;103;0;102;0
WireConnection;103;1;254;0
WireConnection;104;0;103;0
WireConnection;104;2;106;0
WireConnection;69;0;258;0
WireConnection;69;2;74;0
WireConnection;46;0;42;0
WireConnection;259;0;69;0
WireConnection;259;1;70;0
WireConnection;256;0;104;0
WireConnection;256;1;105;0
WireConnection;47;0;46;0
WireConnection;47;1;249;0
WireConnection;187;0;47;0
WireConnection;180;0;259;0
WireConnection;179;0;256;0
WireConnection;213;0;26;0
WireConnection;213;1;11;0
WireConnection;241;0;190;0
WireConnection;241;1;189;0
WireConnection;241;2;250;0
WireConnection;244;0;241;0
WireConnection;214;0;213;0
WireConnection;214;1;9;0
WireConnection;243;0;244;0
WireConnection;243;1;214;0
WireConnection;266;0;265;0
WireConnection;266;1;262;0
WireConnection;23;0;22;0
WireConnection;23;1;243;0
WireConnection;260;0;114;0
WireConnection;260;1;266;0
WireConnection;268;0;260;0
WireConnection;203;0;23;0
WireConnection;240;13;205;0
WireConnection;240;11;269;0
ASEEND*/
//CHKSM=5CE47F2006E7413C8C54B5E1A1F7C00621EFABDB