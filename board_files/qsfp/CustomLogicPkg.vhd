--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: CustomLogicPkg
--    File: CustomLogicPkg.vhd
--  Author: PP
--------------------------------------------------------------------------------
-- The CustomLogic Package defines parameters used during the synthesis process
-- of CustomLogic. The user can set, activate, or remove functionalities from 
-- the CustomLogic framework. This has an impact in the final FPGA resources
-- utilization.
--------------------------------------------------------------------------------
-- 0.1, 2022-11-10, PP, Initial release
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package CustomLogicPkg is
	-- Lookup Table Processing: <'1'> (default value) includes the Lookup Table
	-- Processing module into the CustomLogic framework; <'0'> removes this
	-- functionality from the CustomLogic framework.
	constant LOOKUP_TABLE_PROCESSING_SUPPORTED	: std_logic := '1';
	
end CustomLogicPkg;

package body CustomLogicPkg is
end CustomLogicPkg;
