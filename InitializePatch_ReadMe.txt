Prerequisites (Before Running the Script)
==========================================

- Download 2 files (InitializePatch.sh & Run.sh).

- Create directory OraAuto and put the 2 files inside this directory.

- Create a base directory — this will be referred to as BASE_DIR.

- Move all required source files (patche sources, etc.) into the BASE_DIR.

- Ensure the script is executed with the following input parameters:

# BASE_DIR – The main working directory containing all sources.

# ORACLE_HOME – Path to the Oracle Home directory.

# GRID_HOME – Path to the Grid Infrastructure Home.

# ORACLE_INV – Path to the Oracle Inventory.

# Zip file names – List of patch zip files to be used.

What the Script Does
====================

This script prepares the environment and necessary components for Oracle patching. It performs actions such as:

* Validating input parameters.

* Organizing and extracting patch files.

* Setting up the directory structure required for the patch process.

* Preparing logs and backup directories if necessary.

* Ensuring required permissions and prerequisites are in place before the actual patching steps begin.

* upgrading opatch utility if necessary.(you have to place the zip file in BASE_DIR)
