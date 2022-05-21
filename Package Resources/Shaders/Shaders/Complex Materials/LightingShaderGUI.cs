using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class LightingShaderGUI : ShaderGUI
{
	private MaterialEditor     materialEditor;
	private MaterialProperty[] properties;

	private static readonly GUIContent staticLabel = new GUIContent();
	
	public override void OnGUI (MaterialEditor _materialEditor, MaterialProperty[] _properties)
	{
		materialEditor = _materialEditor;
		properties     = _properties;
		
		DoMain();
	}

	private void DoMain()
	{
		GUILayout.Label("Main Maps", EditorStyles.boldLabel);

		MaterialProperty _mainTexture = FindProperty("_MainTex");
		MaterialProperty _tint        = FindProperty("_Tint");

		materialEditor.TexturePropertySingleLine(MakeLabel(_mainTexture, "Albedo (RGB)"), _mainTexture, _tint);
		
		DoMetallic();
		DoSmoothness();
		DoNormals();
		
		materialEditor.TextureScaleOffsetProperty(_mainTexture);
	}

	private void DoNormals()
	{
		MaterialProperty _map     = FindProperty("_NormalMap");
		MaterialProperty _bumpMap = _map.textureValue ? FindProperty("_BumpScale") : null;
		
		materialEditor.TexturePropertySingleLine(MakeLabel(_map), _map, _bumpMap);
	}
	
	private void DoMetallic () 
	{
		MaterialProperty _slider = FindProperty("_Metallic");

		EditorGUI.indentLevel += 2;
		materialEditor.ShaderProperty(_slider, MakeLabel(_slider));
		EditorGUI.indentLevel -= 2;
	}

	private void DoSmoothness () 
	{
		MaterialProperty _slider = FindProperty("_Smoothness");

		EditorGUI.indentLevel += 2;
		materialEditor.ShaderProperty(_slider, MakeLabel(_slider));
		EditorGUI.indentLevel -= 2;
	}

	private MaterialProperty FindProperty(string _name)
	{
		return FindProperty(_name, properties);
	}
	
	private static GUIContent MakeLabel(string _text, string _tooltip = null) 
	{
		staticLabel.text    = _text;
		staticLabel.tooltip = _tooltip;
		
		return staticLabel;
	}
	
	private static GUIContent MakeLabel(MaterialProperty _property, string _tooltip = null) 
	{
		staticLabel.text    = _property.displayName;
		staticLabel.tooltip = _tooltip;
		
		return staticLabel;
	}
}
