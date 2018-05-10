* Structure:
    * ACDC side:
        * communications handled by lvds_com
            * uses lvds_tranceivers.vhd
                * uses altlvds_tx and altlvds_rx
            * definitions are in Definition_Pool
    * ACC side:
        * communications handled by transceivers from acc_main.vhd
* Simulation
    * Make a project
        * Project name
            * ACC-ACDC communications
        * Project location
            * E:/acc/acc_acdc_sim
        * Default Library name
            * work
        * Copy Settings from 
            * Copy Library mappings
    * Add a folder to the project “acdc”
        * Add existing files to the folder
            * In base source folder
                * deffinition pool
                    * Folder “acdc”
                    * Reference from current location
            * in folder RXTX
                * altlvds_rx0 altlvds_tx0, lvds_com, lvds_transceivers
        * In the Library tab, Make a library for the ACDC code “workacdc”
        * return to project tab
        * Select all files in the folder, right click and select compile->Compile Properties
            * In the general tab, change the “compile to library” to “workacdc”
        * right click on the selected files and choose compile->“compile selected”
    * Add a folder to the project “acc”
        * Add existing files to the folder
            * in the src folder
                * defs
                    * into folder acc
            * in RxTx
                * altvds_*, rx_data_ram, rx_ram, lvds_transceiver, and transceivers.
                    * folder “acc”
    * in Library tab, make a library “workacc”
        * creat: “a new library and a logical mapping to it”
        * name: workacc
        * physical name: workacc
    * back in Project tab, select all files under “acc”
        * right-click, select compile->compile properties
        * in VHDL tab, change Language syntax to “use 1076-2008”
            * Needed for transceivers.vhd
        * in General tab change “compile to library” to “workacc”
    * right-click on selected files and choose compile->Compile selected
    * From the “Compile” menu, select “compile order” and choose “auto generate”
    * (Can now choose compile->Compile all any time, and everything will go to the right place.
    * Make a testbench
        * the testbench will need to load the definitions from the libraries:
            * -- ACC defs
                    library&nbsp;workacc;
                    use&nbsp;workacc.defs.all;
                    --&nbsp;ACDC&nbsp;defs
                    library&nbsp;workacdc;
                    use&nbsp;workacdc.Definition_Pool.all;
            * It also needs the component declaration at the start of the architecture (before begin, so that it can be compiled)
            * The instantiation should be of this form:
                * acc_TRANSCEIVERS : transceivers
                        port&nbsp;map(
                        &nbsp;&nbsp;xCLR_ALL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=>&nbsp;reset_global,
                        &nbsp;&nbsp;xALIGN_ACTIVE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=>&nbsp;xalign_strobe,
                        &nbsp;&nbsp;xALIGN_SUCCESS&nbsp;&nbsp;&nbsp;&nbsp;=>&nbsp;xalign_good,
                    * (without entity or the name of the architecture)
        * If this doesn’t work, may need to link to the resource libraries created before (page 42)
            * modelsimTutorial.pdf
    * make a folder in the project called “testbench”
    * Add the testbench file “acc_acdc_comms_testbench.vhd” to the testbench folder
    * change the compiler settings
        * language syntax use “1076-2009”
        * leave compile to directory as “work”
    * Run the simulation:
        * From the library tab, go to the “work” library and Right click on the testbench architecture and choose “simulate”
        * Run the simulation for “4 us”
        * Check that LVDS_ALIGN_STATE under acc_TRANSCEIVERS is “ALIGN_DONE”