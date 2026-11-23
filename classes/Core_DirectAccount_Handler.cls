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
                // AccToUpdateParent.add(acc.ParentId);
            }
        }
        if(ParentAcc.size() > 0){
            for(Account acc: [Select id,Core_Direct_Primary_Account_Id__c from Account where ID IN :ParentAcc]){
                acc.Core_Direct_Primary_Account_Id__c = null;
                AccLst.add(acc);
                
            }
        }
        update AccLst;
    }
    
    
    
    
    public static void UpdatePrimaryAccOnIntelRec(List<Account>newAccList, Map<Id,Account>oldAccMap){
        system.debug('a');
        List<Account> AccToUpdate = new List<Account>();
        Set<Id> AccToUpdateParent = new Set<Id>();
        for(Account acc:newAccList){
            if(acc.Core_PrimaryAccountCalucationLogic__c ||( acc.RecordTypeId==DirectRecTypeId && acc.Core_Direct_Account_Type_Nm__c != oldAccMap.get(acc.Id).Core_Direct_Account_Type_Nm__c)){
                AccToUpdate.add(acc);
            }
            if(acc.RecordTypeId==DirectRecTypeId &&  acc.ParentId != oldAccMap.get(acc.Id).ParentId ){
                system.debug('######00');
                AccToUpdateParent.add(oldAccMap.get(acc.id).ParentId);
                AccToUpdateParent.add(acc.ParentId);
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
        
        for(Account acc:newAccList){
            system.debug('RecordtypeId'+DirectRecTypeId);
            if(acc.RecordTypeId==DirectRecTypeId && acc.ParentId != null){
                ParentAccIds.add(acc.ParentId);
                //ParentAccIdsLst.add(acc);
            }
            
            
            
        }
        if(ParentAccIds.size() > 0){
            
            List<Account> AccLst=[Select id,Name,ParentId,Core_Direct_Account_Type_Nm__c,CreatedDate from Account where ParentId IN :ParentAccIds ORDER BY CreatedDate DESC];
            ParentAccIdsLst=[Select id,Core_Direct_Account_Type_Nm__c,CreatedDate from Account where ID IN :ParentAccIds ORDER BY CreatedDate DESC];
            System.debug('AccLst' +AccLst);
            System.debug('ParentAccIdsLst'+ParentAccIdsLst);
            for(Account acc : AccLst){
                if(!ParentChildAcc.containskey(acc.ParentId)){
                    ParentChildAcc.put(acc.ParentId, new List<Account>{acc});
                }
                else{
                    ParentChildAcc.get(acc.ParentId).add(acc);
                }
            }
            system.debug('ParentChildAcc'+ParentChildAcc.keyset());
            
            Map<Id,Account> mapDirectAccsToUpdate= new Map<Id,Account>();
            for(Account acc: ParentAccIdsLst){
                List<Account> DirectAccs= new List<Account>();
                system.debug('DirectAccs sie'+DirectAccs.size());
                DirectAccs=ParentChildAcc.get(acc.id);
                List<Account> SoldToAccs= new List<Account>();
                List<Account> ShipToAccs= new List<Account>();
                List<Account> EndCustomerAccs= new List<Account>();
                system.debug('DirectAccs'+DirectAccs);
                system.debug('DirectAccs1'+ParentChildAcc.get(acc.id));
                for(Account a:DirectAccs){
                    if(A.Core_Direct_Account_Type_Nm__c =='Sold To'){
                        SoldToAccs.add(a);
                    }
                    else if(A.Core_Direct_Account_Type_Nm__c =='Ship To'){
                        ShipToAccs.add(a);
                    }
                    else if(A.Core_Direct_Account_Type_Nm__c =='End Customer'){
                        EndCustomerAccs.add(a);
                    }
                    if(mapDirectAccsToUpdate.containsKey(a.Id)){
                        mapDirectAccsToUpdate.get(a.Id).Core_PrimaryAccountCalucationLogic__c = false;
                    }else{
                        a.Core_PrimaryAccountCalucationLogic__c =false;
                        mapDirectAccsToUpdate.put(a.Id,a);
                    }
                }
                if(mapDirectAccsToUpdate.containsKey(acc.Id)){
                    if(SoldToAccs.size()>0){
                        mapDirectAccsToUpdate.get(acc.Id).Core_Direct_Primary_Account_Id__c=SoldToAccs[0].id;
                    }
                    else if(ShipToAccs.size()>0 && SoldToAccs.size()==0){
                        mapDirectAccsToUpdate.get(acc.Id).Core_Direct_Primary_Account_Id__c=ShipToAccs[0].id;                        
                    }
                    else if(EndCustomerAccs.size()>0 && ShipToAccs.size()==0 && SoldToAccs.size()==0){
                        mapDirectAccsToUpdate.get(acc.Id).Core_Direct_Primary_Account_Id__c=EndCustomerAccs[0].id;                        
                    }else {
                        mapDirectAccsToUpdate.get(acc.Id).Core_Direct_Primary_Account_Id__c=null;
                    }
                }else{
                    if(SoldToAccs.size()>0){
                        acc.Core_Direct_Primary_Account_Id__c=SoldToAccs[0].id;
                        mapDirectAccsToUpdate.put(acc.Id,acc);
                    }
                    else if(ShipToAccs.size()>0 && SoldToAccs.size()==0){
                        acc.Core_Direct_Primary_Account_Id__c=ShipToAccs[0].id;
                        mapDirectAccsToUpdate.put(acc.Id,acc);                        
                    }
                    else if(EndCustomerAccs.size()>0 && ShipToAccs.size()==0 && SoldToAccs.size()==0){
                        acc.Core_Direct_Primary_Account_Id__c=EndCustomerAccs[0].id;
                        mapDirectAccsToUpdate.put(acc.Id,acc);                        
                    }else {
                        acc.Core_Direct_Primary_Account_Id__c=null;
                        mapDirectAccsToUpdate.put(acc.Id,acc);
                    }
                }
                
            }
            system.debug('DirectAccsToUpdate-'+mapDirectAccsToUpdate.values());
            //update DirectAccsToUpdate;
            List<Core_Exceptions__c> exList = new List<Core_Exceptions__c>();
            Database.SaveResult[] srr = database.update(mapDirectAccsToUpdate.values(),false);
            for (Database.SaveResult sr : srr) {
                if (!sr.isSuccess()) {
                    Core_Exceptions__c excep = new Core_Exceptions__c();
                    excep.Core_Class_Name__c = 'Core_DirectAccount_Handler';
                    for(Database.Error err : sr.getErrors()) {
                        excep.Core_Exception__c = err.getMessage()+' --'+ err.getFields();
                    }
                    exList.add(excep);
                }
            }
            if(exList.size() >0){
                Insert exList;
                
            }
        }
    }
}