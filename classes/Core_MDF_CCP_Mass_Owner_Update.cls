public with sharing class Core_MDF_CCP_Mass_Owner_Update {
    //Method for retriving Programs List
    @AuraEnabled(cacheable=true)
    public static List<ProgramOptions>  getProgramList(){
        List<ProgramOptions> progOpt = new List<ProgramOptions>();
        for(ChannelProgram cp : [SELECT Core_MDF_Technical_Program_Name__c,name from ChannelProgram WITH SECURITY_ENFORCED order by name asc]){
            ProgramOptions progOptions = new ProgramOptions();
            progOptions.progname = cp.name;
            progOptions.progApiName = cp.Core_MDF_Technical_Program_Name__c;
            if(UserInfo.getUserType() == 'PowerPartner'){
                progOptions.isExternal = true;
            }
            else{
                progOptions.isExternal = false;
            }
            progOpt.add(progOptions);
        }
        return progOpt;
    }

    //Method for retriving the accounts list
    @AuraEnabled(cacheable=true)
    public static List<AccountOptions>  getAccountList (String program){
           List<AccountOptions> accOpt = new List<AccountOptions>();
        
        
                for(Account acc:[select Id,Name,Core_Account_Record_Type__c from Account where Core_Account_Record_Type__c='Intel Account' and Core_MDF_CoMarketingActive__c=true WITH SECURITY_ENFORCED order by Name asc]){
                    AccountOptions accOptions = new AccountOptions();
                    accOptions.accountName = acc.Name;
                    accOptions.accountId = acc.Id;
                    accOptions.isExternal = false;
                    accOpt.add(accOptions);	
            }
        
        return accOpt;
    }
    //Method for retriving the node accounts
    @AuraEnabled(cacheable=true)
    public static List<NodeAccountOptions>  getNodeAccountList(String program,String account){
        List<NodeAccountOptions> nodeaccOpt = new List<NodeAccountOptions>();
                for(Account acc:[select id,name from Account where Core_MDF_CoMarketing_Ultimate_Account__c =: account and Core_MDF_Channel_Program__r.Name=:program WITH SECURITY_ENFORCED order by Name asc]){
                    NodeAccountOptions nodeaccOptions = new NodeAccountOptions();
                    nodeaccOptions.nodeAccountName = acc.name;
                    nodeaccOptions.nodeAccountId = acc.id;
                    nodeaccOptions.isExternal = false;
                    nodeaccOpt.add(nodeaccOptions);	 
                }
        return nodeaccOpt;
    }
    //Method to retrive objects
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getObjectList(String program){
        Map<String,String> custlbl= new Map<String,String>();
        Map<String,String> objApiToObjLabelMap=new Map<String,String>();
        custlbl.put('Client Co-Marketing Fund','Core_MDF_Ext_Obj_create_Perm_CCF');
        custlbl.put('Data Center Co-Marketing Fund','Core_MDF_Ext_Obj_create_Perm_DCF');
        custlbl.put('Client Co-Marketing Fund Boost','Core_MDF_Ext_Obj_create_Perm_CCF_Boost');
        custlbl.put('Service Provider Co-Marketing Fund','Core_MDF_Ext_Obj_create_Perm_SPCF');
        custlbl.put('Intel Partner Alliance','Core_MDF_Ext_Obj_create_Perm_IPA');
        custlbl.put('Retail Marketing Funds','Core_MDF_Ext_Obj_create_Perm_RMF');
         if(UserInfo.getUserType() == 'PowerPartner'){
            //accOpt =Core_MDF_RecoveryClaimReportViewCtrl.getAccountIdToNameMapForExternal(program);
        }
        else{
            if(custlbl.containsKey(program))
            {
                String qualifiedName=custlbl.get(program);
                Core_MDF_Custom_Label_Configration__mdt l=[Select Core_MDF_Value_Txt__c from Core_MDF_Custom_Label_Configration__mdt where QualifiedAPiName=:qualifiedName];
                System.debug(l);
                String s= String.valueOf(l.Core_MDF_Value_Txt__c);
                System.debug('s='+s);
                List<String> ls=s.split(':');
                List<String> arrayls=ls[1].split(',');
                System.debug('list ls='+arrayls);
                for(String objApiName:arrayls)
                {
                    String obj=Schema.getGlobalDescribe().get(objApiName).getDescribe().getLabel();
                    system.debug(obj);
                    objApiToObjLabelMap.put(objApiName,obj);
                }
            }
        }
        return objApiToObjLabelMap;

    }
    //Method to retrive object transactions
    @AuraEnabled(cacheable=true)
    public static List<ObjectTransactions> getobjectTransactions(String program,String account,String nodeAccount,String obj)
    {
        List<ObjectTransactions> objtrans=new List<ObjectTransactions>();
        for(Campaign obje:[select Id,Name from Campaign where Core_MDF_Program__c=:program and Core_MDF_Account__r.name=:nodeAccount and Owner.name='Comarketing FLAO-User' order by name desc])
        {
            ObjectTransactions objtransactions=new ObjectTransactions();
            objtransactions.objectId=obje.Id;
            objtransactions.name=obje.Name;
            objtransactions.program=program;
            objtransactions.accName=nodeAccount;
            objtrans.add(objtransactions);
        }
        System.debug('object transactions'+objtrans);
        return objtrans;
        
    }

    public class AccountOptions {
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Id accountId { get; set; } 
        @AuraEnabled public Boolean isExternal { get; set; } 
    } 
    public class ProgramOptions {
        @AuraEnabled public String progname { get; set; }
        @AuraEnabled public String progApiName { get; set; } 
        @AuraEnabled public Boolean isExternal { get; set; } 
    }
    public class NodeAccountOptions {
        @AuraEnabled public String nodeAccountName { get; set; }
        @AuraEnabled public Id nodeAccountId { get; set; } 
        @AuraEnabled public Boolean isExternal { get; set; } 
    } 
    public class ObjectTransactions
    {
     @AuraEnabled public String accName { get; set; }
     @AuraEnabled public String name  { get; set; } 
     @AuraEnabled public String program { get; set; }  
     @AuraEnabled public Id objectId{ get; set; } 
    }
}