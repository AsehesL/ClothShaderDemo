using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{

    public Vector3 center;
    public float distance;
    public float angle;
    public float speed;
    
	void Start ()
	{
	    transform.eulerAngles = new Vector3(angle, 0, 0);
	    transform.position = center - transform.forward*distance;
	}
	
	void Update ()
	{
	    transform.Rotate(Vector3.up*Time.deltaTime*speed, Space.World);
        transform.position = center - transform.forward * distance;
    }
}
