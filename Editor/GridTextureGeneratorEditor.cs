#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace MugCup_Shader.Editor
{
    [CustomEditor(typeof(GridTextureGenerator))]
    public class GridTextureGeneratorEditor : UnityEditor.Editor
    {
        private GridTextureGenerator gridTextureGenerator;

        private void OnEnable()
        {
            gridTextureGenerator = (GridTextureGenerator)target;
        }

        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();

            if (GUILayout.Button("Generate texture"))
                gridTextureGenerator.GenerateTexture();

            if (GUILayout.Button("Save generated texture"))
                SaveTexture();

            if (GUILayout.Button("Test set pixel colors"))
            {
                gridTextureGenerator.OutputTexture = GridTextureGenerator.CreatBlackTexture(16, 16);
                
                GridTextureGenerator.SetPixelsColor(
                    new []
                    {
                        new Vector2Int(1, 1),
                        new Vector2Int(2, 1),
                        new Vector2Int(3, 1),
                        new Vector2Int(4, 1),
                    }, 
                    gridTextureGenerator.OutputTexture, 
                    Color.white);

                gridTextureGenerator.Material.mainTexture = gridTextureGenerator.OutputTexture;
            }
        }

        private void SaveTexture()
        {
            if (gridTextureGenerator.OutputTexture != null)
            {
                byte[] _textureData = gridTextureGenerator.OutputTexture.EncodeToPNG();
        
                string _path = EditorUtility.SaveFilePanelInProject("Save Texture", "NewTexture", "png", "Save Texture as PNG");
                
                if (_path.Length > 0)
                {
                    System.IO.File.WriteAllBytes(_path, _textureData);
                    AssetDatabase.Refresh();
                }
            }
        }
    }
}
#endif
