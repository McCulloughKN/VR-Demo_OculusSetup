using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorSwap : MonoBehaviour
{
    public List<Material> materials;

    private int index = 0;
    private Renderer rend;

    private void Start()
    {
        rend = GetComponent<Renderer>();
        string materialName = rend.sharedMaterial.name;

        for(int i = 0; i < materials.Count; i++)
        {
            if(materialName.Contains(materials[i].name.ToString()))
            {
                Debug.Log("Found a match");
                index = i;
                break;
            }
        }
    }

    public void SwapColor()
    {
        index = index + 1 < materials.Count ? index + 1 : 0;
        rend.material = materials[index];
    }
}
