--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: CustomLogic_FileIO_pkg
--    File: CustomLogic_FileIO_pkg.vhd
--    Date: 2022-06-03
--     Rev: 0.1
--  Author: MH
--------------------------------------------------------------------------------
-- CustomLogic - Simulation Control File IO package
--------------------------------------------------------------------------------
-- 0.1, 2022-06-03, MH, Initial release
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Simulation_FileIO_pkg is

	-- When feeding the simulation with custom image date, Linux users must
	-- specify the length of the absolute path locating the file containing
	-- the image data.
	-- To do so, update the value of the FILE_PATH_LENGTH constant.
	-- Windows users do not need to update the default FILE_PATH_LENGTH
	-- of 200 characters.

	constant FILE_PATH_LENGTH : natural := 200;

end Simulation_FileIO_pkg;

package body Simulation_FileIO_pkg is
end Simulation_FileIO_pkg;
