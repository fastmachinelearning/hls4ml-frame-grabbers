#######################################################################
### CustomLogic Project                                             ###
#######################################################################
 
To feed the simulation front-end with custom image data:
 
	1) Create a file of any type containing the image data:
    - Linux users must specify the length of the path locating the image data file.
		To do so, update the value of the FILE_PATH_LENGTH constant inside the Simulation_FileIO_pkg.
    	(<user folder>/CoaxlinkOcto_1cam/04_ref_design/sim/Simulation_FileIO_pkg.vhd)
		Windows users do not need to update the default FILE_PATH_LENGTH of 200 characters.
    - The image data must be formatted as ASCII characters representing hexadecimal values.
        - Only ASCII characters '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' are allowed.
        - Each ASCII character represents four bits of data.
        - ASCII characters HT, LF, CR, and SPACE are ignored.
        - Any other ASCII character is replaced by four bits of unknown ('X') value.
    An example .dat file containing image data of a 256x10 Mono8 frame is provided:
    <user folder>/CoaxlinkOcto_1cam/04_ref_design/sim/ImageData_256x10_Mono8.dat
	2) To feed the simulation with the data of the example .dat or any other custom image data:
    - Execute the 'FrameRequest' command inside the 'Simulation' process of the SimulationCtrl_tb
      (<user folder>/CoaxlinkOcto_1cam/04_ref_design/sim/SimulationCtrl_tb.vhd):
        - The 'FrameRequest' <file_path> argument must contain the absolute path to the image data file.
        - The 'FrameRequest' <xsize>, <ysize>, and <pixelf> image metadata arguments must correctly describe the image.
        - The 'FrameRequest' <read_file> argument must be set to 'TRUE'.
        - By setting the 'FrameRequest <big_endian> argument to 'TRUE, Mono16 pixel data is read in the big-endian format.
            Default is little-endian.
        - Ex.: FrameRequest(clk,status,ctrl, 1, 10, 256, 10, Mono8, TRUE, FALSE, "C:/Documents/Image_Data.dat");
 
For more information on CustomLogic, please visit:
	www.euresys.com/en/Support/Online-documentation
 
