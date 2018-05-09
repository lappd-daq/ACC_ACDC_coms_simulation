# ACC_ACDC_coms_simulation

Structure:
==========

  ACDC side:
  ----------

    ### communications handled by lvds\_com

      #### uses lvds\_tranceivers.vhd

        ##### uses altlvds\_tx and altlvds\_rx

      #### definitions are in Definition\_Pool

  ACC side:
  ---------

    ### communications handled by transceivers from acc\_main.vhd

Simulation
==========

  Make a project
  --------------

    ### Project name

      #### ACC-ACDC communications

    ### Project location

      #### E:/acc/acc\_acdc\_sim

    ### Default Library name

      #### work

    ### Copy Settings from

      #### Copy Library mappings

  Add a folder to the project “acdc”
  ----------------------------------

    ### Add existing files to the folder

      #### In base source folder

        ##### deffinition pool

        ###### Folder “acdc”

        ###### Reference from current location

      #### in folder RXTX

        ##### altlvds\_rx0 altlvds\_tx0, lvds\_com, lvds\_transceivers

    ### In the Library tab, Make a library for the ACDC code “workacdc”

    ### return to project tab

    ### Select all files in the folder, right click and select compile-&gt;Compile Properties

      #### In the general tab, change the “compile to library” to “workacdc”

    ### right click on the selected files and choose compile-&gt;“compile selected”

  Add a folder to the project “acc”
  ---------------------------------

    ### Add existing files to the folder

      #### in the src folder

        ##### defs

          ###### into folder acc

      #### in RxTx

        ##### altvds\_\*, rx\_data\_ram, rx\_ram, lvds\_transceiver, and transceivers.

          ###### folder “acc”

  in Library tab, make a library “workacc”
  ----------------------------------------

    ### creat: “a new library and a logical mapping to it”

    ### name: workacc

    ### physical name: workacc

  back in Project tab, select all files under “acc”
  -------------------------------------------------

    ### right-click, select compile-&gt;compile properties

    ### in VHDL tab, change Language syntax to “use 1076-2008”

      #### Needed for transceivers.vhd

    ### in General tab change “compile to library” to “workacc”

  right-click on selected files and choose compile-&gt;Compile selected
  ---------------------------------------------------------------------

  From the “Compile” menu, select “compile order” and choose “auto generate”
  --------------------------------------------------------------------------

  (Can now choose compile-&gt;Compile all any time, and everything will go to the right place.
  --------------------------------------------------------------------------------------------

  Make a testbench
  ----------------

    ### the testbench will need to load the definitions from the libraries:

      #### -- ACC defs library workacc; use workacc.defs.all; -- ACDC defs library workacdc; use workacdc.Definition\_Pool.all;

      #### It also needs the component declaration at the start of the architecture (before begin, so that it can be compiled)

      #### The instantiation should be of this form:

        ##### acc\_TRANSCEIVERS : transceivers port map( xCLR\_ALL =&gt; reset\_global, xALIGN\_ACTIVE =&gt; xalign\_strobe, xALIGN\_SUCCESS =&gt; xalign\_good,

          ###### (without entity or the name of the architecture)

    ### If this doesn’t work, may need to link to the resource libraries created before (page 42)

      #### modelsimTutorial.pdf

  make a folder in the project called “testbench”
  -----------------------------------------------

  Add the testbench file “acc\_acdc\_comms\_testbench.vhd” to the testbench folder
  --------------------------------------------------------------------------------

  change the compiler settings
  ----------------------------

    ### language syntax use “1076-2009”

    ### leave compile to directory as “work”

  Run the simulation:
  -------------------

    ### From the library tab, go to the “work” library and Right click on the testbench architecture and choose “simulate”

    ### Run the simulation for “4 us”

    ### Check that LVDS\_ALIGN\_STATE under acc\_TRANSCEIVERS is “ALIGN\_DONE”