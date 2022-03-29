module EigenShow

using GLMakie, LinearAlgebra, Printf

export eigenshow


# Toby Driscoll (driscoll@udel.edu), March 2022.

# This function is inspired by EIGSHOW.M, which is held in copyright by The MathWorks, Inc and found at:
# Cleve Moler (2021). Cleve_Lab (https://www.mathworks.com/matlabcentral/fileexchange/59085-cleve_lab), MATLAB Central File Exchange. Retrieved October 25, 2021.
"""
    eigenshow()
Demonstrator of geometric intuition behind eigenvectors and singular vectors. 

A figure opens showing a vector 𝑥 on the unit circle and its image 𝐴𝑥 via a given 2x2 matrix 𝐴. 
As you move the mouse around the circle, the image vectors trace out an ellipse. Click the mouse 
to leave a marker for the current source and image vectors.

An eigenvector occurs when 𝐴𝑥 and 𝑥 are parallel, and the associated eigenvalue is the multiplier.
When the toggle is moved to select "svd", then the images of two vectors 𝑥 and 𝑦 are shown while
𝑥 and 𝑦 are kept perpendicular. When the image vectors are also perpendicular, then you are seeing
all of the left and right singular vectors.

The left panel includes a selector of different matrices. Some things to observe: Is the number of
eigenvectors (not counting trivial sign flips) the same in all cases? What about the singular vectors?
Does either set of vectors have any correspondence to the image ellipse? 
"""
function eigenshow()
    fig = Figure(resolution=(1200,800))
    palette = cgrad(:seaborn_colorblind)[1:8]

    ax = Axis(fig[1,2],
        aspect=AxisAspect(1),
        limits=((-1.6,1.6),(-1.6,1.6)),
        xrectzoom=false,yrectzoom=false,
        xpanlock=true,ypanlock=true,
        titlesize=30,
        title=""
    )

    # create matrix menu
    mtx = [[5 0;0 3]/4, [5 0;0 -3]/4, [1 0;0 1], [0 1;1 0], [0 1;-1 0], [1 3;4 2]/4,  [1 3;2 4]/4, [3 1;4 2]/4,  [3 1;-2 4]/4, [2 4;2 4]/4,[2 4;-1 -2]/4, [6 4;-1 2]/4, nothing]
    get_matrix(i) = i < 13 ? mtx[i] : 0.75*randn(2,2)
    label = [ "[5 0;0 3]/4", "[5 0;0 -3]/4", "[1 0;0 1]", "[0 1;1 0]", "[0 1;-1 0]", "[1 3;4 2]/4", "[1 3;2 4]/4", "[3 1;4 2]/4", "[3 1;-2 4]/4", "[2 4;2 4]/4","[2 4;-1 -2]/4", "[6 4;-1 2]/4", "random" ]
    menu = Menu(fig, options=zip(label,mtx),textsize=26,i_selected=6)

    # nodes that define the primary values
    A = @lift( get_matrix($(menu.i_selected)) )
    x = Observable([1.0,0.0])
    y = @lift([-$x[2],$x[1]])

    # pretty-print the matrix for the left panel
    function sprint_matrix(B) 
        if Rational(B[1]).den > 99
            return @sprintf(" %5.2f  %5.2f \n %5.2f  %5.2f",B[[1,3,2,4]]...)
        else
            s = sprint.(show,Rational.(B[[1,3,2,4]]))
            a,b,c,d = replace.(s,"//"=>"/")
            s = "  $a   $b\n  $c   $d"
            s = replace(s," -"=>"-")
            return replace(s,r"(\S+)/1"=>s" \1 ")
        end
    end
    A_lbl = Label(fig,@lift(sprint_matrix($A)),textsize=30,font="mono")

    # toggle for eigen/svd
    toggle = Toggle(fig; active=false) 
    labels = [Label(fig,"eigen",textsize=26),Label(fig,"svd",textsize=26)]

    # widget panel
    panel = fig[1,1] = vgrid!(
        Label(fig,"Choose a matrix",height=30,valign=:bottom,textsize=26),
        menu,
        A_lbl,
        hgrid!(labels[1],toggle,labels[2], tellheight=false),   
    )

    # sets up all the visuals for either vector x, y
    function setup_show(v,c,t)
        vals = Observable{Vector{typeof(v[])}}([])
        dots = scatter!(@lift(Point2.($vals)),color=c[1],markersize=4)
        Avals = Observable{Vector{typeof(v[])}}([])
        Adots = scatter!(@lift(Point2.($Avals)),color=c[2],markersize=4)
        arr = arrows!(ax,[Point2(0.,0.)],@lift([Vec2($v)]),color=c[1],linewidth=5,arrowsize=20)
        arrA = arrows!(ax,[Point2(0.,0.)],@lift([Vec2($A*$v)]),color=c[2],linewidth=5,arrowsize=20)
        txt = text!(L"%$t",position=@lift(Tuple(1.08*$v).+(0.05,0.05)),color=c[1],textsize=36)
        txtA = text!(L"A%$t",position=@lift(Tuple(1.08*$A*$v).+(0.05,0.05)),color=c[2],textsize=36)
        marked = Observable{Vector{typeof(x[])}}([])
        scat = scatter!(@lift(Point2.($marked)),color=c[3],markersize=18)
        return vals,Avals,marked,(;arr,arrA,txt,txtA,scat)
    end

    # create the visuals: source traces, image traces, marked values, visible objects
    x_vals,x_Avals,x_marked,x_obj = setup_show(x,palette,"x")
    y_vals,y_Avals,y_marked,y_obj = setup_show(y,palette,"y")

    # listen when mouse button is clicked: add a marked point
    on(events(fig).mousebutton,priority=1) do event
        if event.button == Mouse.left
            if event.action == Mouse.press
            else
                if norm(mouseposition(ax.scene)) < 1.5
                    append!(x_marked[],[x[],A[]*x[]])
                    #append!(y_marked[],[y[],A[]*y[]])
                    notify.((x_marked,y_marked))
                end
            end
        end
        # Do not consume the event
        return Consume(false)
    end

    # listen when the pointer is moved: add dots to traces
    on(events(fig).mouseposition) do event
        z = mouseposition(ax.scene)
        if norm(z) < 1.5
            x[] = normalize(z)
            push!(x_vals[],x[])
            push!(x_Avals[],A[]*x[])
            push!(y_vals[],y[])
            push!(y_Avals[],A[]*y[])
            notify.((x_vals,x_Avals,y_vals,y_Avals))
        end
        return Consume(false)
    end

    # clear the dot trails
    function clear_dots(dummy)
        obj = (x_vals,x_Avals,x_marked,y_vals,y_Avals,y_marked) 
        [ deleteat!(foo[],eachindex(foo[])) for foo in obj] 
        notify.(obj)
    end

    # listen when a matrix is selected
    on(clear_dots,menu.i_selected) 

    # listen for change in the toggle
    on(toggle.active) do value
        if value
            ax.title = "Make 𝐴𝑥 perpendicular to 𝐴𝑦"
            [ u.visible = true for u in values(y_obj) ]
        else
            ax.title = "Make 𝐴𝑥 parallel to 𝑥"
            [ u.visible = false for u in values(y_obj) ]
        end
        clear_dots(nothing)
    end

    # notify initial state
    toggle.active[] = false

return fig
end
end # module
