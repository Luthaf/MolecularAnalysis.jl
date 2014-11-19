#===============================================================================
                        Compute interesting values
===============================================================================#
import Base: write
export BaseOutput, TrajectoryOutput, CustomOutput

const EOL="\n"
const TAB="\t"

abstract BaseOutput

type TrajectoryOutput <: BaseOutput
    writer::Writer
    frequency::Integer
    current::Integer
end

function TrajectoryOutput(filename::String, frequency=1)
    writer = Writer(filename)
    return TrajectoryOutput(writer, frequency, 0)
end

function write(out::TrajectoryOutput, context::Dict)
    out.current += 1
    if out.current == out.frequency
        write(out.writer, context[:frame])
        out.current = 0
    end
end

# Write to a file, each line containing the results of
# string interpolation on CustomOutput.values
type CustomOutput <: BaseOutput
    file::IOStream
    values::Vector{Symbol}
end

function CustomOutput(filename::String, values::Vector{Symbol},
                            header::String="# Generated by Jumos package")

    file = open(filename, "w")
    write(file, header * EOL)
    return CustomOutput(file, values, header)
end

function write(out::CustomOutput, context::Dict)
    s = ""
    for value in out.values
        if haskey(context, value)
            s *= TAB * context[value]
        else
            error("Value not found for output: $(KeyError.key)")
        end
    end
    write(out.file, s * EOL)
end
