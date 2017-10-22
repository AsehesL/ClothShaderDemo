using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightController : MonoBehaviour
{
	
	// Update is called once per frame
    void OnGUI()
    {
        Vector3 ang = transform.eulerAngles;
        GUI.color = Color.black;
        GUI.Label(new Rect(0, 0, Screen.width*0.1f, Screen.height*0.05f), "灯光旋转");
        ang.y = GUI.HorizontalSlider(new Rect(0, Screen.height*0.05f, Screen.width*0.1f, Screen.height*0.05f), ang.y, 0, 360);
        transform.eulerAngles = ang;
    }
}
