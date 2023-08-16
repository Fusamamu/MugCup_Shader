using System.Collections;
using System.Collections.Generic;
using UnityEditor.Graphs;
using UnityEngine;

namespace MugCup_Shader
{
    //Need to move to MugCup Utility Package
    public class GridTextureGenerator : MonoBehaviour
    {
        public int TextureSize = 32; 
       
        public Color color1 = Color.white; 
        public Color color2 = Color.black;
        
        public Texture2D OutputTexture;

        //Temp
        public Material Material;
 
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

        public static Texture2D CreatBlackTexture(int _width, int _height)
        {
            var _texture = new Texture2D(_width, _height);

            for (var _y = 0; _y < _height; _y++)
                for (var _x = 0; _x < _width; _x++)
                    _texture.SetPixel(_x, _y, Color.black);

            _texture.Apply();

            return _texture;
        }

        public static Texture2D CreateTextureColor(int _width, int _height, Color _color)
        {
            var _texture = new Texture2D(_width, _height);

            for (var _y = 0; _y < _height; _y++)
                for (var _x = 0; _x < _width; _x++)
                    _texture.SetPixel(_x, _y, _color);

            _texture.Apply();

            return _texture;
        }

        public static void SetPixelsColor(IEnumerable<Vector2Int> _pixelCoord, Texture2D _texture, Color _color)
        {
            Color[] _pixels = _texture.GetPixels();

            foreach (var _pos in _pixelCoord)
                _pixels[_pos.x + _pos.y * _texture.width] = _color;
            
            _texture.SetPixels(_pixels);
            _texture.filterMode = FilterMode.Point;
            _texture.Apply();
        }
    }
}
