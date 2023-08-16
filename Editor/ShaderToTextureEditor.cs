#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace MugCup_Shader.Editor
{
    [CustomEditor(typeof(ShaderToTexture))]
    public class ShaderToTextureEditor : UnityEditor.Editor
    {
        private ShaderToTexture shaderToTexture;

        private void OnEnable()
        {
            shaderToTexture = (ShaderToTexture)target;
        }

        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();

            if (GUILayout.Button("Generate texture"))
                shaderToTexture.GenerateTextureFromShader();

            if (GUILayout.Button("Save generated texture"))
                SaveTexture();
        }
        
        private void SaveTexture()
        {
            if (shaderToTexture.OutputTexture != null)
            {
                byte[] _textureData = shaderToTexture.OutputTexture.EncodeToPNG();
        
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
