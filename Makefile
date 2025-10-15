VIVADO = vivado -mode tcl
PROJECT_DIR := project

# Create the Vivado project
create:
	$(VIVADO) -source scripts/create_project.tcl -tclargs clean

# Update the Vivado project by cleaning and recreating it
update:
	$(MAKE) clean_project
	$(VIVADO) -source scripts/create_project.tcl -tclargs clean

# Delete everything except .gitignore
clean_project:
	find $(PROJECT_DIR) -mindepth 1 ! -name ".gitignore" -exec rm -rf {} +