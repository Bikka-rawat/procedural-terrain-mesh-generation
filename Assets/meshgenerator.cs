using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(MeshFilter))]
public class meshgenerator : MonoBehaviour
{
	Mesh mesh;



	[SerializeField] int xSize;
	[SerializeField] int zSize;

	Vector3[] vertices;
	int[] triangles;

	[SerializeField] Gradient gradient;

	Color[] color;

	float minheight;
	float maxheight;


	void Start()
	{
		mesh = new Mesh();
		GetComponent<MeshFilter>().mesh = mesh;


		
		

	}
    private void Update()
    {
		createshape();
		updatemesh();
    }



    void createshape()
	{
		vertices = new Vector3[(xSize + 1) * (zSize + 1)];
		color = new Color[vertices.Length];

		for (int i = 0, z = 0; z <= zSize; z++)
		{
			for (int x = 0; x <= xSize; x++)
			{
				float y = Mathf.PerlinNoise(x * .3f, z * .3f) * 2f;
				vertices[i] = new Vector3(x, y, z);
				if (y > maxheight) { maxheight = y; }
				else if (y < minheight) { minheight = y; }


				
				i++;
			}
		}

		triangles = new int[xSize * zSize * 6];

		int vert = 0;
		int tris = 0;

		for (int z = 0; z < zSize; z++)
		{

			for (int x = 0; x < xSize; x++)
			{
				triangles[tris + 0] = vert + 0;
				triangles[tris + 1] = vert + xSize + 1;
				triangles[tris + 2] = vert + 1;
				triangles[tris + 3] = vert + 1;
				triangles[tris + 4] = vert + xSize + 1;
				triangles[tris + 5] = vert + xSize + 2;

				vert++;
				tris += 6;

			}
			vert++;
		}

		for (int i = 0, z = 0; z <= zSize; z++)
		{
			for (int x = 0; x <= xSize; x++)
			{
				float height =Mathf.InverseLerp(minheight,maxheight, vertices[i].y);

				color[i] = gradient.Evaluate(height);
				i++;
			}
		}


	}

	void updatemesh()
	{
		mesh.Clear();

		mesh.vertices = vertices;
		mesh.triangles = triangles;
		mesh.colors = color;
		mesh.RecalculateNormals();
	}
}



