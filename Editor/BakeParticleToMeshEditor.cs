using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using MugCup.Shader.Runtime;

namespace MugCup.Shader.Editor
{
    [CustomEditor(typeof(BakeParticleToMesh))]
    public class BakeParticleToMeshEditor : UnityEditor.Editor
    {
        public override void OnInspectorGUI() 
        {
            base.OnInspectorGUI();

            if (GUILayout.Button("Bake")) 
            {
                ((BakeParticleToMesh)target).SaveAsset();
            }
        }
    }
}
