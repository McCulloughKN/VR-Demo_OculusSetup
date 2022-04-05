using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class HighlightHandler : MonoBehaviour
{
    private Material material;

    private void Start()
    {
        material = GetComponent<MeshRenderer>().material;
    }

    public void ToggleHighlight(bool toggle)
    {
        if (material != null)
        {
            material.SetFloat("_ShowOutline", toggle ? 1 : 0);
        }
    }
}
