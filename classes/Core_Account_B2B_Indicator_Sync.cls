/******************************************************************************************************************************************
Class Name  : Core_Account_B2B_Indicator_Sync
Version     : 1.0
Created Date: 10 NOV 2022
Function    : Business logic for unchecking B2B Flag on Account via the sync job   

Modification Log :
* Developer                 				Date                    Description
* ----------------------------------------------------------------------------
* Akshay More [Team Draco]                 10-Nov-2022              Original version
*****************************************************************************************************************************************/

public class Core_Account_B2B_Indicator_Sync {
    
    @InvocableMethod(label='Sync B2B Flag on Account' description=' Uncheck B2B Flag on Account if all the contacts associated to an Account have no entitlements and are no B2B flag' category= 'Entitlement')
    public static void syncB2BFlagOnAccount() { 
    
    }
}