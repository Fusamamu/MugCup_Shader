using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MugCup_Shader
{
    public class GridTextureGenerator : MonoBehaviour
    {
        public int TextureSize = 32; 
       
        public Color color1 = Color.white; 
        public Color color2 = Color.black;
        
        public Texture2D OutputTexture;

        public void GenerateTexture()
        {
            CreateCheckerboard();
        }

        private void CreateCheckerboard()
        {
            OutputTexture = new Texture2D(TextureSize, TextureSize);

            for (var _y = 0; _y < TextureSize; _y++)
            {
                for (var _x = 0; _x < TextureSize; _x++)
                {
                    Color _pixelColor = (_x + _y) % 2 == 0 ? color1 : color2;
                    OutputTexture.SetPixel(_x, _y, _pixelColor);
                }
            }

            OutputTexture.Apply();
        }
    }
}
