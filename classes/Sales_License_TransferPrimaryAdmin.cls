/***************************************************************************
Class Name    : Sales_License_TransferPrimaryAdmin
Version       : 1.0
Created Date  : May 2021
Function      : Updated the primary admin contact using lwc tab

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           11-June-2021              
* *********************************************************************************************************************/
public without sharing class Sales_License_TransferPrimaryAdmin {

    @AuraEnabled
    //getting the from contact and to contact Id from LWC Tab
    public static void updatehostcontact(Id fromPrimayAdmin, Id toPrimaryAdmin){
        system.debug('inside updatehostcontact fromPrimayAdmin'  +fromPrimayAdmin+  'toPrimaryAdmin'   +toPrimaryAdmin);
        list<Sales_Host__c> salesHostList = new list<Sales_Host__c>();
        //checking the from and to contact Id is not null
        if(fromPrimayAdmin!=null && toPrimaryAdmin!=null && fromPrimayAdmin!=toPrimaryAdmin){
            system.debug('###Inside IF updatehostcontact');
        //Sales_License_TransferPrimaryAdmin.updateDelegateAdmin(fromPrimayAdmin,toPrimaryAdmin);
        //Sales_License_TransferPrimaryAdmin.updateLicenseRec(fromPrimayAdmin,toPrimaryAdmin);
        //getting all the host record which are related from contact and updating it to new contact
            for(Sales_Host__c hostrec :[SELECT id,Name,Sales_Contact__c,Sales_Companion_Server1_Txt__c, Sales_Companion_Server2_Txt__c  FROM Sales_Host__c WHERE Sales_Contact__c=:fromPrimayAdmin
                                       and Sales_Companion_Server2_Txt__c!=null and Sales_Companion_Server1_Txt__c!=null]){
                hostrec.Sales_Contact__c=toPrimaryAdmin;
                salesHostList.add(hostrec);
            }
        }
        update salesHostList;
        system.debug('salesHostList'+salesHostList);
    }

    @AuraEnabled
    public static void updateDelegateAdmin(Id fromContact,Id toContact){
        system.debug('inside updateDelegateAdim fromContact'  +fromContact+   'toContact'   +toContact);
        List<Sales_License_Admin_Delegate__c> delegatedAdminList = new List<Sales_License_Admin_Delegate__c>();
        //getting the all delegate admin related to old contact and updating to the new contact on the delegated admin record page
        for(Sales_License_Admin_Delegate__c salesDelegateAdmin:[SELECT id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_isActive__c FROM Sales_License_Admin_Delegate__c WHERE Sales_License_PrimaryAdmin_Contact__c=:fromContact AND Sales_License_isActive__c=true]){
            salesDelegateAdmin.Sales_License_PrimaryAdmin_Contact__c=toContact;
            delegatedAdminList.add(salesDelegateAdmin);
        }
        update delegatedAdminList;
        system.debug('delegatedAdminList'+delegatedAdminList);
    }

    @AuraEnabled
    public static void updateLicenseRec(Id fromContact,Id toContact){
        system.debug('inside updateLicenseRec fromContact'  +fromContact+   'toContact' +toContact);
            list<Sales_License__c> updatelicenseList = new list<Sales_License__c>();
            //getting the account id related to new conact
            Contact conRec = [SELECT id,AccountId FROM Contact WHERE id=:toContact];
            //getting all the licenese related to old contact and updating it to new contact and also updating the account on the license record
            for(Sales_License__c salesLicenserec :[SELECT id,Name,Sales_License_Primary_Admin_Contact__c FROM Sales_License__c WHERE Sales_License_Primary_Admin_Contact__c=:fromContact]){
                salesLicenserec.Sales_License_Primary_Admin_Contact__c=toContact;
                salesLicenserec.Sales_License_Account__c=conRec.AccountId;
                updatelicenseList.add(salesLicenserec);
            }
            update updatelicenseList;
            system.debug('updatelicenseList'+updatelicenseList);
        }
    
    
    /*****************************************************
     * Method : checkLicenseAdminDelegateCanBeTransferred
     * Developer : Shivam Vishwakarma
     * @return value : 
     * 		Reason for deciding return value : On License Admin Delegate Object -> Validation rule : Delegate Admin Contact and Primary Admin Contact cannot be same.
     * 		True => There exists no Active License Admin Delegate Object record where FromContact is Primary Admin & ToContact is a Delegate to the Primary Admin
     * 		False => else False, we were able to find such a record and it will throw the Validation Rule.
    *****************************************************/
    /*@AuraEnabled
    public static Boolean checkLicenseAdminDelegateCanBeTransferred(Id fromContact,Id toContact){
        Boolean result=false;
        system.debug('checkLicenseAdminDelegateCanBeTransferred - fromContact:'  +fromContact+   ' toContact:'   +toContact);
        try{
             List<Sales_License_Admin_Delegate__c> delegatedAdminList = [SELECT Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c,Sales_License_isActive__c 
                                                                    FROM Sales_License_Admin_Delegate__c 
                                                                    WHERE Sales_License_PrimaryAdmin_Contact__c=:fromContact AND Sales_License_DlgAdmin_Contact__c=:toContact AND Sales_License_isActive__c=true];
            if(!delegatedAdminList.isEmpty())
                result = false;
            else
                result = true;
			            
        }catch(Exception e){
            System.debug('@@checkLicenseAdminDelegateCanBeTransferred Error --> '+ e.getMessage());
            result = false;                        
        }
        return result;
    }
*/
    
}