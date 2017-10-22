using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallController : MonoBehaviour
{

    public float height;

    public float speed;

    private Vector3 m_BeginPos;
    private Vector3 m_EndPos;
    
	void Start ()
	{
	    m_BeginPos = transform.position;
	    m_EndPos = transform.position + Vector3.up*height;
	}
	
	void Update ()
	{
	    transform.position = Vector3.Lerp(m_BeginPos, m_EndPos, Mathf.Abs(Mathf.Sin(Time.time*speed)));
	}
}
