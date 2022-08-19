# Particle Simulator

A Complete rewrite of the <a href="https://github.com/halalabubu/N-Body-Simulation">original version</a>.
<p>An N-Body particle simulator that supports two methods of calculating the total force being applied to each particle.</p>
<ul>
<li>The naive approach which for every particle it calculates every other particles pull. (N^2)</li>
<li>The Barnes-Hut method which groups particles and approximates them by calculating the center of mass and total mass. If the center of mass is sufficiently far away then this approximation is used. (N*log(N)) (N^2)</li>
</ul>

# Methods
<p>1: Naive</p>
<p>2: BarnesHut</p>
<p>3: Build tree from leaves (bottom up approach)(no sorting required)</p>

# API's
<p>CUDA</p>
<p>OPENGL</p>
<p>GLFW</p>
<p>IMGUI</p>


<img src="https://user-images.githubusercontent.com/35517078/185715571-e1cf60e2-d20d-493b-a3aa-291ec7c1ab0c.png" width="100%"></img>
