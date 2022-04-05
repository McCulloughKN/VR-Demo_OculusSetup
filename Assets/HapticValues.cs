using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Haptic Values", menuName = "Haptic Values")]
public class HapticValues : ScriptableObject
{
    [SerializeField]
    private float durationValue;
    [SerializeField]
    [Range(0, 1)]
    private float frequencyValue;
    [SerializeField]
    [Range(0, 1)]
    private float amplitudeValue;

    public float Duration()
    {
        return durationValue;
    }

    public float Frequency()
    {
        return frequencyValue;
    }

    public float Amplitude()
    {
        return amplitudeValue;
    }
}
