/******************************************************************************************************************************************
Class Name  : ER_WhitelistBlackList_Input
Version     : 1.0
Created Date: 10 May 2021
Function    : API to provide all the Whitelisted & Blacklisted Email Domains
Team Name   : Enterprise Registration (Team Quest)

Modification Log :
* Developer Date Description
* -------------------------------------------------------------------------------------------
* Shreeka, Harshitha  10/05/2021 Original version

******************************************************************************************************************************************/
public class ER_WhitelistBlackList_Input 
{
	public String ProgramCode {set;get;}
    public String EntitlementName {set;get;}
    
    public static ER_WhitelistBlackList_Input parse(String json) 
    {
        return (ER_WhitelistBlackList_Input) System.JSON.deserialize(json, ER_WhitelistBlackList_Input.class);
    }
}