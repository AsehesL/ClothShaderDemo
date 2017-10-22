Shader "Unlit/ClothShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BumpTex("NormalMap", 2D) = "bump" {}
		_BodyColor("BodyColor", color) = (1,1,1,1)
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0, 12)) = 3
		_Specular("Specular", Range(0, 1)) = 0.2
		_Gloss("Gloss", Range(0, 1)) = 0.2
		_Transmittance("Transmittance", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			cull off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase 
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 bumpuv : TEXCOORD1;
				float4 RT0 : TEXCOORD2;
				float4 RT1 : TEXCOORD3;
				float4 RT2 : TEXCOORD4;
				UNITY_FOG_COORDS(5)
				SHADOW_COORDS(6)
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float4 _RimColor;
			float _RimPower;
			float _Specular;
			float _Gloss;

			float4 _BodyColor;
			float _Transmittance;

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.bumpuv = TRANSFORM_TEX(v.texcoord, _BumpTex);
				
				UNITY_TRANSFER_FOG(o,o.pos);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);//计算世界坐标

																	 //切空间计算
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);//切空间z轴
				float3 worldTan = UnityObjectToWorldDir(v.tangent.xyz);//切空间x轴
				float tanSign = v.tangent.w * unity_WorldTransformParams.w;
				float3 worldBinormal = cross(worldNormal, worldTan)*tanSign;//切空间y轴

				o.RT0 = float4(worldTan.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.RT1 = float4(worldTan.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.RT2 = float4(worldTan.z, worldBinormal.z, worldNormal.z, worldPos.z);

				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				float3 worldPos = float3(i.RT0.w, i.RT1.w, i.RT2.w);
				float3 rnormal = UnpackNormal(tex2D(_BumpTex, i.bumpuv));//DXT5nm将法线压缩到ga通道
				float3 worldNormal = float3(dot(i.RT0.xyz, rnormal), dot(i.RT1.xyz, rnormal), dot(i.RT2.xyz, rnormal));
				
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos)

				float3 litDir = normalize(UnityWorldSpaceLightDir(worldPos.xyz));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos.xyz));

				half3 halfVec = normalize(litDir + viewDir);

				float ndvSign = sign(dot(worldNormal, viewDir));//通过法线和视线的点积判断当前的面的朝向
				float ndl = abs(dot(worldNormal, litDir))*0.5 + 0.5;
				float ndh = abs(dot(worldNormal, halfVec));

				float spec = pow(ndh, _Specular*128.0) * _Gloss;

				float nde = pow(1 - abs(dot(normalize(worldNormal), viewDir)), _RimPower);


				float ndlS = 1 - saturate(max(0,dot(worldNormal, litDir)*ndvSign));//计算一个衰减值，其只影响背光面

				float3 lightCol = lerp(_LightColor0.rgb, _LightColor0.rgb * _BodyColor.rgb * col.rgb * _Transmittance, ndlS);

				col.rgb = col.rgb * (UNITY_LIGHTMODEL_AMBIENT.rgb + lightCol* ndl*atten) + (spec+nde)*_RimColor*atten;
				//col.rgb *= UNITY_LIGHTMODEL_AMBIENT.rgb + (lightCol*ndl + spec* finalSpecMask*_FresnelColor)*atten;

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
		Pass{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }

			cull off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG

		}
	}
}
