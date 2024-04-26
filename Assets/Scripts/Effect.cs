

using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class Effect : MonoBehaviour
{
    public Material material;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {    
        Graphics.Blit(src, dest, material);
    }
}
