using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
using System.IO;
#endif

namespace MugCup.Shader.Runtime
{
    [RequireComponent(typeof(ParticleSystem))]
    public class BakeParticleToMesh : MonoBehaviour 
    {
	    public string folderPath = "Meshes";
	    public string fileName   = "NewBakedParticleSystemMesh";
        
	    public bool keepVertexColors = true;

	    public enum NormalType 
        {
		    KeepNormals,
		    NormalizedVertexPosition,
		    ClearNormals
	    }

	    public NormalType handleNormals;

#if UNITY_EDITOR
        [ContextMenu("Bake To Mesh Asset")]
        public void SaveAsset() {
            
            Mesh _mesh = new Mesh();
            
            GetComponent<ParticleSystemRenderer>().BakeMesh(_mesh, true);
            
            if (!keepVertexColors)
                _mesh.colors32 = null;
            
            
            switch (handleNormals) 
            {
                case NormalType.KeepNormals:
                    break;
                
                
                case NormalType.NormalizedVertexPosition:
                    
                    Vector3[] _normals = _mesh.vertices;
                    
                    int _length = _normals.Length;
                    
                    for (var _i = 0; _i < _length; _i++) 
                        _normals[_i] = _normals[_i].normalized;
                    
                    _mesh.normals = _normals;
                    break;
                    
                case NormalType.ClearNormals:
                    _mesh.normals = null;
                    break;
            }

            string _fileName = Path.GetFileNameWithoutExtension(fileName) + ".asset";
            
            Directory.CreateDirectory("Assets/" + folderPath);
            
            string _assetPath = "Assets/" + folderPath + "/" + _fileName;

            var _existingAsset = AssetDatabase.LoadAssetAtPath<Object>(_assetPath);
            
            if (_existingAsset == null) 
            {
                AssetDatabase.CreateAsset(_mesh, _assetPath);
            } 
            else 
            {
                if (_existingAsset is Mesh)
                    (_existingAsset as Mesh).Clear();
                
                EditorUtility.CopySerialized(_mesh, _existingAsset);
            }
            
            AssetDatabase.SaveAssets();
        }
#endif
    }
}
