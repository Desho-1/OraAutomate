Prerequisites (Before Running the Script)
==========================================

1- Download 2 files (InitializePatch.sh & Run.sh).

2- Create directory OraAuto inside root directory and put the 2 files inside OraAuto directory.

3- Create a base directory — this will be referred to as BASE_DIR.

4- Move all required source files (patche sources, etc.) into the BASE_DIR.

5- Ensure the scripts are executable, you should expect the following input parameters:

- BASE_DIR – The main working directory containing all sources.

- ORACLE_HOME – Path to the Oracle Home directory.

- GRID_HOME – Path to the Grid Infrastructure Home.

- ORACLE_INV – Path to the Oracle Inventory.

- Zip file names – List of patch zip files to be used.

What the Script Does
====================

This script prepares the environment and necessary components for Oracle patching. It performs actions such as:

* Validating input parameters.

* Organizing and extracting patch files.

* Backup Oracle Inventory, Oracle and grid homes.

* Setting up the directory structure required for the patch process.

* Preparing logs and backup directories if necessary.

* Ensuring required permissions and prerequisites are in place before the actual patching steps begin.

* upgrading opatch utility if necessary.(you have to place the zip file in BASE_DIR)

  

How to Run ?
============

- As Root type: ./InitializePatch.sh
