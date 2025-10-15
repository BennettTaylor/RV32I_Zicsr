# create_project.tcl

set argv0 [lindex $argv 0]
set proj_name "RV32I_Zicsr"
set proj_dir  "../project"

create_project $proj_name $proj_dir -part xc7a100tcsg324-1 -force

# Clean old project files
if {[string equal $argv0 "clean"] && [file exists $proj_dir]} {
    puts "Cleaning old project directory..."
    # Delete everything except .gitignore
    set files [glob -nocomplain -directory $proj_dir *]
    foreach f $files {
        if {[file tail $f] ne ".gitignore"} {
            file delete -force $f
        }
    }
}

# Add sources
add_files -fileset sources_1 [glob ../src/rtl/*.v]
add_files -fileset sim_1 [glob ../src/sim/*.v]
add_files -scan_for_includes [glob ../src/include/*.vh]

# Add constraints
add_files -fileset constrs_1 [glob ../constraints/*.xdc]

# Set top module
set_property top top [current_fileset]

# Set simulation top
set_property top tb_top [get_filesets sim_1]

# Save project
save_project_as $proj_name $proj_dir/$proj_name.xpr

# Launch GUI
start_gui