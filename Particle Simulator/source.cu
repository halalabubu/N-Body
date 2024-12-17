#include "imgui.h"
#include"imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

#include "glad.h"
#include <GLFW/glfw3.h>
#include <iostream>

#include <fstream>
#include <string>

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"


#include <cuda_runtime.h>
#include <cuda_gl_interop.h>

#include "kernel.cuh"


const int WIDTH = 2000;
const int HEIGHT = 1200;
const float GRIDL = 800;
const int PCOUNT = 1000;

const int BLOCKSIZE = 128;
const int NUMBLOCKS = (PCOUNT + BLOCKSIZE - 1) / BLOCKSIZE;


void initParts(Particle* parts, const int PCOUNT);
void randPos(Particle* parts, const int PCOUN, const int Limit);

int main()
{
	glfwInit();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	//create window
	GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "N-Body Simulation", NULL, NULL);
	glfwMakeContextCurrent(window);
	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
		std::cout << "Failed to initialize OpenGL context" << std::endl;
		return -1;
	}

	glViewport(0, 0, WIDTH, HEIGHT);





	//glClearColor(0.07f, 0.13f, 0.17f, 1.0f);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

	std::string fragShaderString;
	std::string vertShaderString;

	//load shader files
	std::ifstream file("shaders/Fragment.frag");
	if (file.fail())
		std::cout << "It failed\n" << strerror(errno) << std::endl;
	if (file)
	{
		std::string contents((std::istreambuf_iterator<char>(file)),
			std::istreambuf_iterator<char>());

		fragShaderString = contents;
	}
	file.close();
	file.open("shaders/Vertex.vert");
	if (file.fail())
		std::cout << "It failed\n" << strerror(errno) << std::endl;
	if (file)
	{
		std::string contents((std::istreambuf_iterator<char>(file)),
			std::istreambuf_iterator<char>());

		vertShaderString = contents;
	}
	file.close();
	const char* vShader = vertShaderString.c_str();
	const char* fShader = fragShaderString.c_str();

	//std::cout << "Vert shader Below\n" << std::endl;
	//std::cout << vShader << std::endl;
	//std::cout << "Frag shader Below\n" << std::endl;
	//std::cout << fShader << std::endl;

	// a triangle
	float vertices[PCOUNT * 3];




	//bind shaders
	GLuint vertShader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertShader, 1, &vShader, NULL);
	glCompileShader(vertShader);
	GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragShader, 1, &fShader, NULL);
	glCompileShader(fragShader);

	//create shaders to shaderProgram
	GLuint shaderProgram = glCreateProgram();
	glAttachShader(shaderProgram, vertShader);
	glAttachShader(shaderProgram, fragShader);
	glLinkProgram(shaderProgram);
	glUseProgram(shaderProgram);

	//these are not needed anymore
	glDeleteShader(vertShader);
	glDeleteShader(fragShader);

	GLuint VAO, VBO;
	glGenVertexArrays(1, &VAO);
	glGenBuffers(1, &VBO);
	//bind the vertex array to use
	glBindVertexArray(VAO);
	//bind the buffer object to use
	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);

	//select vertex attrib to modify
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
	glEnableVertexAttribArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);

	float rotation = 0.0f;
	double prevTime = glfwGetTime();

	glPointSize(6.0f);
	glEnable(GL_POINT_SMOOTH);
	glEnable(GL_BLEND);
	//glBlendFunc(GL_DST_ALPHA, GL_SRC_ALPHA);
	glBlendFunc(GL_SRC_ALPHA, GL_DST_ALPHA);



	//glEnable(GL_DEPTH_TEST);

	//register the buffer object to cuda memory space
	//cudaGLRegisterBufferObject(VBO);
	cudaGraphicsResource* resource;
	//cudaGraphicsGLRegisterBuffer(&resource, VBO, cudaGLMapFlagsNone);
	//cudaGraphicsMapResources(1, &resource, 0);
	void** vertPointer;
	float3* vertsPtr;
	size_t mappedSize;
	// Map the buffer to CUDA
	//cudaGraphicsResourceGetMappedPointer((void**)&vertsPtr, &mappedSize, resource);
	//cudaGLMapBufferObject(&vertPointer, VBO);
	// Run a kernel to create/manipulate the data
	//testKernal << <1, 1 >> > (vertsPtr);

	// Unmap the buffer // must be unmapped for opengl to use
	//cudaDeviceSynchronize();
	//cudaGraphicsUnmapResources(1, &resource,0);

	Particle* parts;
	Particle* temp;
	temp = new Particle[PCOUNT];




	cudaMalloc(&parts, PCOUNT * sizeof(Particle));
	initParts(temp, PCOUNT);
	randPos(temp, PCOUNT, 80);



	cudaMemcpy(parts, temp, PCOUNT * sizeof(Particle), cudaMemcpyHostToDevice);

	IMGUI_CHECKVERSION();
	ImGui::CreateContext();
	ImGuiIO& io = ImGui::GetIO(); (void)io;
	ImGui::StyleColorsDark();
	ImGui_ImplGlfw_InitForOpenGL(window, true);
	ImGui_ImplOpenGL3_Init("#version 330");









	bool pause = false;
	float delta = 0.005;
	float rotateAmount = 0.2f;
	float zoom = -100.0f;

	//glfwSwapBuffers(window);
	while (!glfwWindowShouldClose(window))
	{
		glClear(GL_COLOR_BUFFER_BIT);

		ImGui_ImplOpenGL3_NewFrame();
		ImGui_ImplGlfw_NewFrame();
		ImGui::NewFrame();

		ImGui::Begin("Nope");
		ImGui::Text("Please?");
		ImGui::Checkbox("Pause", &pause);
		ImGui::SliderFloat("Delta", &delta, 0.0001f, 0.1f);
		ImGui::SliderFloat("Rotation speed", &rotateAmount, 0.0f, 1.0f);
		ImGui::SliderFloat("Zoom?", &zoom, -100.0f, 100.0f);
		ImGui::End();


		double crntTime = glfwGetTime();

		rotation += rotateAmount;
		prevTime = crntTime;

		glm::mat4 proj = glm::mat4(1.0f);
		glm::mat4 model = glm::mat4(1.0f);
		glm::mat4 view = glm::mat4(1.0f);

		proj = glm::perspective(glm::radians(60.0f), (float)WIDTH/(float)HEIGHT, 0.01f, 1000.0f);
		model = glm::rotate(model, glm::radians(rotation), glm::vec3(0.0f, 1.0f, 0.0f));
		view = glm::translate(view, glm::vec3(0.0f, 0.0f, zoom));


		int modelLoc = glGetUniformLocation(shaderProgram, "model");
		glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
		int viewLoc = glGetUniformLocation(shaderProgram, "view");
		glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
		int projLoc = glGetUniformLocation(shaderProgram, "proj");
		glUniformMatrix4fv(projLoc, 1, GL_FALSE, glm::value_ptr(proj));


		//glBindBuffer(GL_ARRAY_BUFFER, 0);
		//glBindVertexArray(0);
		cudaGraphicsGLRegisterBuffer(&resource, VBO, cudaGLMapFlagsNone);
		cudaGraphicsMapResources(1, &resource, 0);


		cudaGraphicsResourceGetMappedPointer((void**)&vertsPtr, &mappedSize, resource);
		//cudaGLMapBufferObject(&vertPointer, VBO);
		// Run a kernel to create/manipulate the data
		//testKernal << <1, 1 >> > (vertsPtr);
		if (pause == false)
		{
			naiveNBody << <NUMBLOCKS, BLOCKSIZE >> > (parts, vertsPtr, PCOUNT, delta);
			cudaDeviceSynchronize();
			updateVertexBuffer << < NUMBLOCKS, BLOCKSIZE >> > (parts, vertsPtr, PCOUNT);
		}




		// Unmap the buffer // must be unmapped for opengl to use
		//cudaDeviceSynchronize();
		cudaGraphicsUnmapResources(1, &resource, 0);





		ImGui::Render();
		ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());



		glBindVertexArray(VAO);

		glDrawArrays(GL_POINTS, 0, PCOUNT);
		glfwSwapBuffers(window);





		glfwPollEvents();



	}


	ImGui_ImplGlfw_Shutdown();
	ImGui_ImplOpenGL3_Shutdown();
	ImGui::DestroyContext();


	//delete objects before program close
	glDeleteVertexArrays(1, &VAO);
	glDeleteBuffers(1, &VBO);
	glDeleteProgram(shaderProgram);

	glfwDestroyWindow(window);
	glfwTerminate();
	return 0;
}
//sets all values to 0
void initParts(Particle* partsTmp, const int PCOUNT) {
	for (size_t i = 0; i < PCOUNT; i++)
	{
		partsTmp[i].velocity.x = 0;
		partsTmp[i].velocity.y = 0;
		partsTmp[i].velocity.z = 0;
		partsTmp[i].position.x = 0;
		partsTmp[i].position.y = 0;
		partsTmp[i].position.z = 0;
	}


}

void randPos(Particle* parts, const int PCOUNT, const int Limit)
{
	for (size_t i = 0; i < PCOUNT; i++)
	{
		float temp;
		temp = rand()%1000;
		temp = temp * 0.0001;



		parts[i].position.x = (rand() % Limit - Limit / 2)+temp;
		parts[i].position.y = (rand() % Limit - Limit / 2)+temp;
		parts[i].position.z = (rand() % Limit - Limit / 2)+temp;
		//std::cout << parts[i].position.x << std::endl;
	}



}
