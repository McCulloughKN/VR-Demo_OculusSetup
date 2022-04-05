using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OVR;

public class ControllerHandler : MonoBehaviour
{
    public bool debug;
    public OVRInput.Controller controller;

    public float interactDistance;
    public LayerMask interactionMask;
    public float pressThreshold;
    public HapticValues hapticInfo;
    public Transform grabTransform;

    private float triggerInput;
    private bool canInteract = true;
    private bool triggerIsPressed = false;
    private bool canPlayHaptics = true;

    private InteractableObject curInteractable;

    void Update()
    {
       triggerInput = OVRInput.Get(OVRInput.Axis1D.PrimaryIndexTrigger, controller);

       triggerIsPressed = triggerInput > pressThreshold ? true : false;

        if (triggerIsPressed)
        {
            if(curInteractable != null && canInteract)
            {
                if (curInteractable.IsGrabbable())
                {
                    canInteract = false;
                    GrabObject(curInteractable);
                }
            }
        }
        else
        {
            if(curInteractable != null)
            {
                ReleaseObject(curInteractable);
                curInteractable = null;
            }

            canInteract = true;
        }

        if (OVRInput.GetDown(OVRInput.Button.One, controller))
        {
            if (curInteractable != null && canInteract)
            {
                SelectObject(curInteractable);
            }
        }

        if (canInteract)
        {
            RaycastHit hit;

            if (Physics.Raycast(grabTransform.position, Vector3.forward, out hit, interactDistance, interactionMask))
            {
                var hitObj = hit.transform.gameObject;
                Debug.Log("Hit Object: " + hitObj);

                var interactObj = hitObj.GetComponent<InteractableObject>();
                if (interactObj != null && interactObj.IsInteractable())
                {
                    SetFocusObject(interactObj);
                }

            }
            else
            {
                if (curInteractable != null)
                {
                    SetFocusObject(null);
                }
            }
        }
    }

    private void SetFocusObject(InteractableObject interactObj)
    {
        if(curInteractable != null) curInteractable.SetFocus(false);

        curInteractable = interactObj;
        if(interactObj != null) curInteractable.SetFocus(true);
    }

    private void OnDrawGizmos()
    {
        if (debug)
        {
            Gizmos.DrawWireSphere(grabTransform.position, interactDistance);
        }
    }

    private void GrabObject(InteractableObject obj)
    {
        HapticResponse(hapticInfo);
        obj.Grab(grabTransform);
    }

    private void ReleaseObject(InteractableObject obj)
    {
        obj.Release();
    }

    private void SelectObject(InteractableObject obj)
    {
        HapticResponse(hapticInfo);
        obj.Select();
    }

    private void HapticResponse(HapticValues haptic)
    {
        StartCoroutine(HapticResponseOp(haptic));
    }

    //private void OnTriggerEnter(Collider other)
    //{
    //    var interactObj = other.GetComponent<InteractableObject>();
    //    if (interactObj != null && interactObj.IsInteractable())
    //    {
    //        curInteractable = interactObj;
    //    }
    //}

    //private void OnTriggerExit(Collider other)
    //{
    //    curInteractable = null;
    //}

    IEnumerator HapticResponseOp(HapticValues haptic)
    {
        OVRInput.SetControllerVibration(haptic.Frequency(), haptic.Amplitude(), controller);
        yield return new WaitForSeconds(haptic.Duration());
        OVRInput.SetControllerVibration(0, 0, controller);
        canPlayHaptics = true;
        yield break;
    }
}
