/********************************
Apex Class Name:  Core_DirectAccount_Handler
Version     : 1.0 
Created Date: 24 March 2021
Function    : methods to handle the Direct Primary account caluculation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Mahesh                 24/03/2021              Original Version
*************************************************************************************/

public class Core_DirectAccount_Handler {

public static String DirectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Account').getRecordTypeId();

      public static void UpdatePrimaryAccAsBlank(List<Account>newAccList,Map<Id,Account>oldAccMap){
        Set<Id>ParentAcc= new Set<Id>();
        List<Account> AccLst = new List<Account>();
        List<Account> OldAccLst = new List<Account>();
        Map<Id,List<Account>> ParentChildAcc= new Map<Id,List<Account>>();   
        for(Account Act:newAccList){
            if(Act.RecordTypeId==DirectRecTypeId &&  Act.ParentId != oldAccMap.get(Act.Id).ParentId ){
            system.debug('######00');
            ParentAcc.add(oldAccMap.get(Act.id).ParentId);
           // AccToUpdateParent.add(Acc.ParentId);          
        }           
        }
        if(ParentAcc.size() > 0){
        for(Account Acc: [Select id,Core_Direct_Primary_Account_Id__c from Account where ID IN :ParentAcc]){
            Acc.Core_Direct_Primary_Account_Id__c = null;
            AccLst.add(Acc);
            
        }
        }
        update AccLst;
    }
        
    
    

 public static void UpdatePrimaryAccOnIntelRec(List<Account>newAccList, Map<Id,Account>oldAccMap){
     system.debug('a');
    List<Account> AccToUpdate = new List<Account>();
    Set<Id> AccToUpdateParent = new Set<Id>();
    for(Account Acc:newAccList){
        if(Acc.Core_PrimaryAccountCalucationLogic__c ||( Acc.RecordTypeId==DirectRecTypeId && Acc.Core_Direct_Account_Type_Nm__c != oldAccMap.get(Acc.Id).Core_Direct_Account_Type_Nm__c)){
        	AccToUpdate.add(Acc);      
        }
         if(Acc.RecordTypeId==DirectRecTypeId &&  Acc.ParentId != oldAccMap.get(Acc.Id).ParentId ){
            system.debug('######00');
            AccToUpdateParent.add(oldAccMap.get(Acc.id).ParentId);
            AccToUpdateParent.add(Acc.ParentId);            
        }                                        
    }
    
    if(AccToUpdate.size()>0){
        UpdatePrimaryAcc(AccToUpdate);
    }
    system.debug('01'+AccToUpdateParent);
    if(AccToUpdateParent.size()>0){
        system.debug('02'+AccToUpdateParent);
        List<Account> AllDirectAcc=[Select id,CreatedDate,RecordTypeId,Core_Direct_Account_Type_Nm__c,ParentId from Account where ParentId IN :AccToUpdateParent AND RecordTypeId =: DirectRecTypeId];
        
        UpdatePrimaryAcc(AllDirectAcc);
    }
    
}




    public static void UpdatePrimaryAcc(List<Account>newAccList){
        system.debug('03');
        Map<Id,List<Account>> ParentChildAcc= new Map<Id,List<Account>>();   
        Set<Id> ParentAccIds= new Set<Id>();
        List<Account> ParentAccIdsLst= new List<Account>();
        
        for(Account Acc:newAccList){
            system.debug('RecordtypeId'+DirectRecTypeId);
            if(Acc.RecordTypeId==DirectRecTypeId && Acc.ParentId != null){
                ParentAccIds.add(acc.ParentId);
                //ParentAccIdsLst.add(acc);
            }
            
            
            
        }
        if(ParentAccIds.size() > 0){
      
        List<Account> AccLst=[Select id,Name,ParentId,Core_Direct_Account_Type_Nm__c,CreatedDate from Account where ParentId IN :ParentAccIds ORDER BY CreatedDate DESC];
        ParentAccIdsLst=[Select id,Core_Direct_Account_Type_Nm__c,CreatedDate from Account where ID IN :ParentAccIds ORDER BY CreatedDate DESC];
        for(Account acc : AccLst){
            if(!ParentChildAcc.containskey(Acc.ParentId)){
                ParentChildAcc.put(Acc.ParentId, new List<Account>{Acc});
            }
            else{
                ParentChildAcc.get(Acc.ParentId).add(Acc);
            }   
        }
        system.debug('ParentChildAcc'+ParentChildAcc.keyset()); 
    
        List<Account> DirectAccsToUpdate= new List<Account>();
         for(Account Acc: ParentAccIdsLst){
            List<Account> DirectAccs= new List<Account>();
             system.debug('DirectAccs sie'+DirectAccs.size());
             DirectAccs=ParentChildAcc.get(Acc.id);
             List<Account> SoldToAccs= new List<Account>();
             List<Account> ShipToAccs= new List<Account>();
              List<Account> EndCustomerAccs= new List<Account>();
             system.debug('DirectAccs'+DirectAccs);
             system.debug('DirectAccs1'+ParentChildAcc.get(Acc.id));
         for(Account A:DirectAccs){
             if(A.Core_Direct_Account_Type_Nm__c =='Sold To'){
                 SoldToAccs.add(A);
                 }
             else if(A.Core_Direct_Account_Type_Nm__c =='Ship To'){
                 ShipToAccs.add(A);
                 }
             else if(A.Core_Direct_Account_Type_Nm__c =='End Customer'){
                 EndCustomerAccs.add(A);
             }
             A.Core_PrimaryAccountCalucationLogic__c =false;
             DirectAccsToUpdate.add(a);
         }
         if(SoldToAccs.size()>0){
            Acc.Core_Direct_Primary_Account_Id__c=SoldToAccs[0].id;
            DirectAccsToUpdate.add(Acc);
         }
         else if(ShipToAccs.size()>0 && SoldToAccs.size()==0){
            Acc.Core_Direct_Primary_Account_Id__c=ShipToAccs[0].id;
            DirectAccsToUpdate.add(Acc);
             
         }
          else if(EndCustomerAccs.size()>0 && ShipToAccs.size()==0 && SoldToAccs.size()==0){
            Acc.Core_Direct_Primary_Account_Id__c=EndCustomerAccs[0].id;
            DirectAccsToUpdate.add(Acc);
             
         }else {
             Acc.Core_Direct_Primary_Account_Id__c=null;
            DirectAccsToUpdate.add(Acc);
         }
         
             
         }
            system.debug('DirectAccsToUpdate-'+DirectAccsToUpdate);
            //update DirectAccsToUpdate;
            List<Core_Exceptions__c> exList = new List<Core_Exceptions__c>();
            Database.SaveResult[] srr = database.update(DirectAccsToUpdate,false);
            for (Database.SaveResult sr : srr) {
                    if (sr.isSuccess()) {
                    }
                    else if (!sr.isSuccess()){
                        Core_Exceptions__c excep = new Core_Exceptions__c();
                        excep.Core_Class_Name__c = 'Core_DirectAccount_Handler';
                        for(Database.Error err : sr.getErrors()) {
                            excep.Core_Exception__c = err.getMessage()+' --'+ err.getFields();
                        }
                        exList.add(excep);
                    }
                }
            if(exList.size() >0){
                insert exList;

            }
        }
    }
}