Shader "Custom/TriplanarShader" {
    Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Blend ("Blend", Range(0, 1)) = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv_MainTex : TEXCOORD2;
                float2 uv_NormalMap : TEXCOORD3;
                UNITY_FOG_COORDS(4)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            float _Blend;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = mul(unity_ObjectToWorld, float4(v.normal, 0.0)).xyz;
                o.uv_MainTex = v.vertex.xz; // Adjust UV coordinates here as needed
                o.uv_NormalMap = v.vertex.xy; // Adjust UV coordinates here as needed
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 blend = abs(i.worldNormal);
                float3 blendWeights = blend / (blend.x + blend.y + blend.z);

                float3 triplanarX = tex2D(_MainTex, i.uv_MainTex.yz).rgb * blendWeights.x;
                float3 triplanarY = tex2D(_MainTex, i.uv_MainTex.xz).rgb * blendWeights.y;
                float3 triplanarZ = tex2D(_MainTex, i.uv_MainTex.xy).rgb * blendWeights.z;

                float3 triplanarColor = (triplanarX + triplanarY + triplanarZ) / (blendWeights.x + blendWeights.y + blendWeights.z);
                return lerp(fixed4(triplanarColor, 1.0), tex2D(_MainTex, i.uv_MainTex).rgba, _Blend);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}


