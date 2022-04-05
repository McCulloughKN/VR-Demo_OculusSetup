using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class InteractableObject : MonoBehaviour
{
    [SerializeField]
    private bool interactable = true;
    [SerializeField]
    private bool grabbable = false;

    [Space(10)]
    [SerializeField]
    private bool returnOnRelease;

    //Unity events
    [SerializeField]
    private UnityEvent OnHover;
    [SerializeField]
    private UnityEvent OnHoverEnd;
    [SerializeField]
    private UnityEvent OnSelect;
    [SerializeField]
    private UnityEvent OnGrab;
    [SerializeField]
    private UnityEvent OnRelease;

    private Transform originalParent;
    private Vector3 originalPos;
    private Vector3 originalRot;

    private bool isFocused = false;
    private bool isHovering = false;

    void Start()
    {
        originalParent = transform.parent;
        originalPos = transform.localPosition;
        originalRot = transform.localEulerAngles;
    }

    void Update()
    {
        if (isFocused)
        {
            if (!isHovering) Hover();
        }
        else
        {
            if(isHovering) HoverEnd();
        }
    }

    public bool IsGrabbable()
    {
        return grabbable;
    }

    public bool IsInteractable()
    {
        return interactable;
    }

    public void Hover()
    {
        isHovering = true;
        OnHover.Invoke();
    }

    public void HoverEnd()
    {
        isHovering = false;
        OnHoverEnd.Invoke();
    }

    public void Select()
    {
        OnSelect.Invoke();
    }

    public void SetFocus(bool focus)
    {
        Debug.Log("Setting focus on " + gameObject.name + ": " + focus);
        isFocused = focus;
    }

    public void Grab(Transform transform)
    {
        transform.parent = transform;
        transform.localPosition = Vector3.zero;
        OnGrab.Invoke();
    }

    public void Release()
    {
        OnRelease.Invoke();
        transform.parent = originalParent;

        if (returnOnRelease)
        {
            transform.localPosition = originalPos;
            transform.localEulerAngles = originalRot;
        }
    }
}
