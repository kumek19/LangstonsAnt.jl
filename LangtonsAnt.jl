using Plots
using FileIO
using ArgParse

# option parser
function parse_args()
    s = ArgParseSettings()
    @add_arg_table s begin
        "-g", "--grid-size"
            help = "grid size"
            arg_type = Int
            default = 200
        "-d", "--direction"
            help = "ant direction: 0: up, 1: right, 2: down, 3: left"
            arg_type = Int
            default = 0
        "-s", "--steps"
            help = "step number"
            arg_type = Int
            default = 12000
        "-o", "--out"
            help = "output file name"
            arg_type = String
            default = "langtons_ant"
    end
    return ArgParse.parse_args(s)
end

args = parse_args()

const GRID_SIZE = args["grid-size"]
const INITIAL_DIRECTION = args["direction"]
const STEPS = args["steps"]
const OUT = args["out"]*".gif"


# Ant direction
const DIRECTIONS = [(0,1), (1,0), (0,-1), (-1,0)]

# Ant 
mutable struct Ant
    x::Int
    y::Int
    direction::Int  
end

# Ant move function 
function move!(grid, ant)
    if grid[ant.x, ant.y] == 0  # white grid -> turn right and change to black 
        ant.direction = mod(ant.direction + 1, 4)
        grid[ant.x, ant.y] = 1
    else  # black grid -> turn left and change to white 
        ant.direction = mod(ant.direction - 1, 4)
        grid[ant.x, ant.y] = 0
    end
    
    # move to new position 
    dx, dy = DIRECTIONS[ant.direction + 1]
    ant.x = mod1(ant.x + dx, GRID_SIZE)
    ant.y = mod1(ant.y + dy, GRID_SIZE)
end

# simulation function 
function simulate(steps)
    grid = zeros(Int, GRID_SIZE, GRID_SIZE)
    ant = Ant(div(GRID_SIZE,2), div(GRID_SIZE,2), 0)
    
    frames = []

    for step in 1:steps
        move!(grid, ant)
        if step % 100 == 0  # 100ステップごとに記録
            push!(frames, heatmap(grid, color=palette(:grays, rev=true), title="Step $step"))
        end
    end
    
    return frames
end

# run simulation 
frames = simulate(STEPS)

# animation 
anim = @animate for frame in frames
    plot(frame)
end

gif(anim, OUT, fps=10)
