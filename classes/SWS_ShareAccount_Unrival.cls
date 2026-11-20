/****************************************************************************************************
Apex Class Name : SWS_ShareAccount_Unrival
Version         : 1.0 
Created Date    : 2025-06-18
Function        : Unrival logic for Account sharing with Unrival Integration User.
User Story      : TWC5945-1428
Test Class      : SWS_ShareAccount_UnrivalTest
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shijas KM              2025-06-18                 Created
*****************************************************************************************************/

public without sharing class SWS_ShareAccount_Unrival {
  	public class UnrivalAccounts {
        @InvocableVariable(required=true)
        public Id accountId;
        @InvocableVariable(required=true)
        public string Shared_With_Unrival;
      
    }
    @InvocableMethod(label='ShareAccount_Unrival' description='ShareAccount_Unrival')
    public static void ShareAccount_Unrival(List<UnrivalAccounts> inputs){
        
        ShareAccount(inputs);
       
    }
    
    private static void ShareAccount(List<UnrivalAccounts> inputs) {
         List<Account> AccountsEnabled = new List<Account>();
     
         if (!inputs.isEmpty()) {   				
              for (UnrivalAccounts unrivalAcc : inputs) {
                  Boolean boolValue = (unrivalAcc.Shared_With_Unrival != null && unrivalAcc.Shared_With_Unrival.toLowerCase() == 'true');
                  system.debug('code data');
                  system.debug(unrivalAcc.accountId);
                  system.debug(unrivalAcc.Shared_With_Unrival);
                  Account acc = new Account();
                  acc.Id= unrivalAcc.accountId;
            	  acc.Is_Shared_With_Unrival__c = boolValue;
                  AccountsEnabled.add(acc);
        }
          if (!AccountsEnabled.isEmpty()) { 
               if (Schema.sObjectType.Account.isUpdateable() ) 
               {
        		update AccountsEnabled;
    		   }               
			}
			}
        
    }
    
	}