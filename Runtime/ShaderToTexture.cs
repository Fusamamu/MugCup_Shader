using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MugCup_Shader
{
    public class ShaderToTexture : MonoBehaviour
    {
        public Material Material;
        public Texture2D OutputTexture;
        
        public int TextureLength = 1024;

        public void GenerateTextureFromShader()
        {
            RenderTexture _renderTextureBuffer = new RenderTexture(TextureLength, TextureLength, 0, RenderTextureFormat.ARGB32);

            Graphics.Blit(null, _renderTextureBuffer, Material);

            RenderTexture.active = _renderTextureBuffer;
            OutputTexture = new Texture2D(TextureLength, TextureLength, TextureFormat.ARGB32, true);
            OutputTexture.ReadPixels(new Rect(0, 0, _renderTextureBuffer.width, _renderTextureBuffer.height), 0, 0);
            OutputTexture.Apply();
            RenderTexture.active = null;
        }
    }
}
