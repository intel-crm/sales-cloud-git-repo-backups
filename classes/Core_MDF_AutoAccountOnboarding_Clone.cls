public without sharing class Core_MDF_AutoAccountOnboarding_Clone {
    public static String alertMessage{get;set;} 
    //Map of technical program name to program abbrivated name
    public static Map<string,string> prgmAbbName = new Map<string,string>();
    //Map of technical program name to program Id
    public static Map<string,Id> prgmIdMap = new Map<string,Id>();
    //List of accounts
    public static List<Account> accountList = new List<Account>();
    //set of accounts in AGM
    public static Map<Id,Id> mapOfIntelAccountandOpId = new Map<Id,Id>();
    //Map of Op Id and related List of Intel Accounts
    public static Map<Id, Set<Id>> mapOfOpIdSetofAccountId = new Map<Id, Set<Id>>();
    //Map of All Intel Accounts and corresponding Op Id
    public static Map<Id,Id> mapOfAllIntelAcctsIdOpId = new Map<Id, Id>(); 
    
    /*****************************************************************************************************
Method Name:        createPublicGroup
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create public group
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/ 
    public static void createPublicGroup(List<Core_MDF_CCPAccountOnboardWrapper> accountsToOnboard)
    {
        //To hold group name
        String groupName;
        //To hold group developer name
        String groupDeveloperName;
        //To hold account name length
        Integer accountNameLength;
        //To hold group list
        List<Group> grpList = new List<Group>();
        for(Core_MDF_CCPAccountOnboardWrapper accWrap : accountsToOnboard)
        {
            groupDeveloperName = 'Core_MDF_CCP_'+String.valueOf(accWrap.account.Id)+'_'+prgmAbbName.get(accWrap.program)+'_'+'EXT';
            groupName = 'CCP '+String.valueOf(accWrap.account.Id)+ ' ' + prgmAbbName.get(accWrap.program) + ' ' + ' EXT';
            System.debug('groupName:' + groupName);
            System.debug('groupDeveloperName:' + groupDeveloperName);
            Group newGroup = new Group();
            newGroup.Name = groupName;
            newGroup.DeveloperName = groupDeveloperName;
            grpList.add(newGroup);
            accWrap.grpDevName = newGroup.DeveloperName;
        }
        //Check if grp exists and then change the name and insert
        Database.insert(grpList);   
    }
    
    
    /****************************************************************************************************** 
Method Name:        createPGM
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create partner group mapping
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/    
    public static void createPGM(List<Core_MDF_CCPAccountOnboardWrapper> accountsToOnboard)
    {
        //List of partner group mapping
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        for(Core_MDF_CCPAccountOnboardWrapper accWrap : accountsToOnboard)
        {
            //New PGM instance
            Core_MDF_Partner_Group_Mapping__c newPGM = new Core_MDF_Partner_Group_Mapping__c();
            newPGM.Core_MDF_Account__c = accWrap.account.Id;
            newPGM.Core_MDF_Channel_Program__c = prgmIdMap.get(accWrap.program);
            newPGM.Core_MDF_Group_Name__c = accWrap.grpDevName;
            newPGM.Core_MDF_Type_of_Access__c = 'External';
            pgmList.add(newPGM);
        }
        Database.insert(pgmList);
    }
    
    /****************************************************************************************************** 
Method Name:        createCorpNode
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to create corp node
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/        
     public static void createCorpNode(List<Core_MDF_CCPAccountOnboardWrapper> accountsToOnboard)
    {
        //List of accounts
        List<Account> accList = new List<Account>();
        //co-marketing record type Id
        ID coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
        //ID retailMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        for(Core_MDF_CCPAccountOnboardWrapper accWrap : accountsToOnboard)
        {
            //New Account Instance
            Account corpAcc = new Account();            
            corpAcc.RecordTypeId = coMarketingRecordTypeId;
            //corpAcc.Core_MDF_CoMarketingActive__c = true;
            corpAcc.Core_MDF_Parent_Fund_Account__c = accWrap.account.Id;
            corpAcc.Core_MDF_Channel_Program__c = prgmIdMap.get(accWrap.program); 
            corpAcc.Core_Geo__c = accWrap.account.Core_Geo__c;
            corpAcc.Core_Sub_Geo__c = accWrap.account.Core_Sub_Geo__c;           
          //  corpAcc.Name = string.isBlank(accWrap.vcName)?(prgmAbbName.get(accWrap.program)+' - ' + accWrap.account.Name):accWrap.vcName;
			//corpAcc.Name = ((string.isBlank(accWrap.vcName)) || (accWrap.vcName == NULL))?(prgmAbbName.get(accWrap.program)+' _ ' + accWrap.account.Name):accWrap.vcName;
			corpAcc.Name  = (accWrap.vcName == NULL)?(prgmAbbName.get(accWrap.program)+' _ ' + accWrap.account.Name):accWrap.vcName;                                
            accList.add(corpAcc);                  
        }
        //Insert accounts        
        Database.insert(accList);
    }
    
    /****************************************************************************************************** 
Method Name:        onboardAccountToCCP
@return  :          N/A
@parameters:        list of ccp account wrapper
Description:        This method is used to on board accounts to CCP
Added By:           Accenture - SM - 7/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/ 
    public static void onboardAccountToCCP(List<Core_MDF_CCPAccountOnboardWrapper> accountsToOnboard)
    {
        //set of program
        Set<string> prgmSet = new Set<string>();
        List<Core_MDF_CCPAccountOnboardWrapper> vcToBeCreatedList=new List<Core_MDF_CCPAccountOnboardWrapper>();
        for(Core_MDF_CCPAccountOnboardWrapper accWrap : accountsToOnboard)
        {
            prgmSet.add(accWrap.program.replace('®',''));
            accountList.add(accWrap.account);
            if(accWrap.vcToBeCreated){
                vcToBeCreatedList.add(accWrap);  
            }
        }
        //Preparing map of technical program name to program Id
        for(ChannelProgram prgm : [Select Id, Core_MDF_Technical_Program_Name__c, Name 
                                   from ChannelProgram 
                                   where Core_MDF_Technical_Program_Name__c IN :prgmSet])
        {
            prgmIdMap.put(prgm.Core_MDF_Technical_Program_Name__c, prgm.Id);   
        }
        //Preparing map of technical program name to program abbrivated name
        for(Core_MDF_ChannelProgram__mdt cpm : [SELECT Core_MDF_Abbreviated_ProgramName_txt__c, Core_MDF_Technical_Program_Name__c, MasterLabel
                                                FROM Core_MDF_ChannelProgram__mdt
                                                WHERE Core_MDF_Technical_Program_Name__c IN :prgmSet])
        {
            prgmAbbName.put(cpm.Core_MDF_Technical_Program_Name__c, cpm.Core_MDF_Abbreviated_ProgramName_txt__c);
        }
        //Create public group
            createPublicGroup(accountsToOnboard);
            
            //Create parter group mapping
            createPGM(accountsToOnboard);
            //Create CCP corp node
            System.debug('@@vcToBeCreatedList'+vcToBeCreatedList);
            createCorpNode(vcToBeCreatedList); 
    }
    
 
}