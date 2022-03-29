# EigenShow.jl
Interactive demonstrator of eigenvectors and singular vectors for Julia

## Usage

1. [Install Julia.](https://julialang.org/download) Version 1.7 or greater is recommended.
2. Start Julia and enter the command
    
    ```julia
    ]add EigenShow
    ```

    It may take a few minutes to download and install the necessary packages.
3. Enter the commands
    
    ```julia
    using EigenShow
    eigenshow()
    ```

    (The `using` command is needed only once per Julia session.) After 20 seconds or so, a new window should open with the demonstrator. It runs independently and can simply be closed when you are done with it.

**In EVD mode.** Initially you see a vector $x$ on the unit circle and, in a different color, the vector $Ax$ resulting from matrix-vector multiplication using the current matrix $A$ chosen in the selection box. As you move the mouse, $x$ moves around the unit circle and $Ax$ traces out an ellipse (or, in a degenerate case, a line segment). When $Ax$ is parallel to $x$, then $x$ is an eigenvector of $A$, and the (signed) ratio of the vector lengths is the associated eigenvalue. When $x$ is an eigenvector, so is $-x$. The matrix may have zero, one, or two distinct real eigenvectors.

**In SVD mode.** As you move the mouse, a perpendicular pair of vectors $x,y$ move around the unit circle. In a different color, you also see $Ax$ and $Ay$ for the current matrix $A$ chosen in the selection box. When $Ax$ and $Ay$ are perpendicular to each other, then $x$ and $y$ are right singular vectors of $A$, $Ax$ and $Ay$ are left singular vectors of $A$, and the (unsigned) ratios of lengths of $Ax$ to $x$ and $Ay$ to $y$ are associated singular values. Aside from the trivial duplications $x ↦ -x$ and $y ↦ -y$, every real $2\times 2$ matrix has a unique pair of real right singular vectors.

In either mode, you can click the mouse button to mark a point for future reference. 

## Acknowledgement

This function is inspired by EIGSHOW.M, which is held in copyright by The MathWorks, Inc and found at:
Cleve Moler (2021), [Cleve_Lab](https://www.mathworks.com/matlabcentral/fileexchange/59085-cleve_lab), MATLAB Central File Exchange. Retrieved October 25, 2021.
