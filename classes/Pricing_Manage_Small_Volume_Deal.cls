/****************************************************************************************************
Apex Class Name : Pricing_Manage_Small_Volume_Deal
Version         : 1.0 
Created Date    : -
Function        : This class is used as controller for New Quote button LWC 
Modifications   :
*****************************************************************************************************
* Developer : Anjali                             
*****************************************************************************************************/

public without sharing class Pricing_Manage_Small_Volume_Deal  extends TriggerHandler {
    public static Boolean isTestRunning = false;
	@AuraEnabled(cacheable=true)
    public static Id getAccount(String userId){
        if(userId!=null){
             Id accountId = [Select Contact.AccountId from User where Id =: userId LIMIT 1].Contact.AccountId;
        	return accountId;
        }else{
            return null;
        }
    }   
    
    @AuraEnabled//(cacheable=true)
    public static Boolean isRecordTypeSelectionAllowed(String accId) {
        Boolean isquoteProgramAllowed;
        if(accId!=null){
            List<Pricing_QuoteProgram_CAPSize__c> quoteProgramList = getcapSizeOfAccountSVD(accId);
               
            if(quoteProgramList.size() > 0) {
                if(quoteProgramList[0].Pricing_Active_cb__c == true && quoteProgramList[0].Pricing_Account_Id__c == accId) {
                    isquoteProgramAllowed = true;
                } else {
                    isquoteProgramAllowed = false;
                }
            } else {
                isquoteProgramAllowed = false;
            }
            
            return isquoteProgramAllowed;
        }
        else{
            return null;
        }
    }
    
   @AuraEnabled//(cacheable=true)
    public static String capSizeCheck(String accId) {
        String svdCreationAllowed;     
        if(accId!=null){
            Integer countInCurrentQuarter = getcountOfQuotesInQuarter(accId);
            List<Pricing_QuoteProgram_CAPSize__c> quoteProgram = getcapSizeOfAccountSVD(accId);
            
            if(quoteProgram.size() > 0) {
                if(quoteProgram[0].Pricing_Active_cb__c == true) {
                    Decimal capSize = quoteProgram[0].Pricing_Small_Deal_CAP_size_Number__c;
                    svdCreationAllowed = (quoteProgram[0].Pricing_Small_Deal_CAP_size_Number__c <= countInCurrentQuarter) ? 'false:'+capSize+':'+(capSize-countInCurrentQuarter) : 'true:'+capSize+':'+(capSize-countInCurrentQuarter);
                } else {
                    svdCreationAllowed = 'false:'+quoteProgram[0].Pricing_Small_Deal_CAP_size_Number__c+':'+(quoteProgram[0].Pricing_Small_Deal_CAP_size_Number__c-countInCurrentQuarter);
                }
            } else {
                 svdCreationAllowed = 'true:'+ 0+':'+0;
            }
            return svdCreationAllowed;   
        }else {
            return null;
        }
        
    }
    

    public static Map<String,Boolean> isRecordTypeSelectionAllow(String accId) {
       //Boolean isquoteProgramAllowed;
       Map<String,Boolean> isquoteProgramAllowed = new Map<String,Boolean>();
       if(accId!=null){
           List<Pricing_Systematic_Tender_Limitation__c> quoteProgramList = getcapSizeOfAccount(new Set<String>{accId});
              
           if(quoteProgramList.size() > 0) {
               for(Pricing_Systematic_Tender_Limitation__c quoteProgram : quoteProgramList){
                   if(quoteProgram.Pricing_Active_cb__c == true && quoteProgram.Pricing_Account__c == accId) {
                       //isquoteProgramAllowed = true;
                       isquoteProgramAllowed.put(quoteProgram.Pricing_Quote_Type__c,true);
                   }
               }
           }
           return isquoteProgramAllowed;
       }
       else{
           return isquoteProgramAllowed;
       }
    }

    public static Map<String,String> capSizeCheckToCreation(Set<String> accIds,Boolean isDataCenterClientQuoteAPI) {  
        try{
            Map<String,String> svdCreationAllowed = new Map<String,String>(); 
            // Set<String> accIdsSet = new Set<String>(accIds); 
             if(accIds.size() > 0){
                 Map<String,Integer> qTypeToNoOfQuotesMap = new Map<String,Integer>(getcountOfQuotesInQuarters(accIds));
                 List<Pricing_Systematic_Tender_Limitation__c> quoteProgramList = getcapSizeOfAccount(accIds);
                 if(quoteProgramList.size() > 0) {
                     String creationAllowed;
                     for(Pricing_Systematic_Tender_Limitation__c quoteProgram : quoteProgramList){
     
                         if(qTypeToNoOfQuotesMap.size()>0 && qTypeToNoOfQuotesMap.containskey(quoteProgram.Pricing_Quote_Type__c+':'+quoteProgram.Pricing_Account__c) && quoteProgram.Pricing_Active_cb__c == true) {///if record is present we will check no of quoes// if record is inactive and not present then don't check and allow then to 
                         Decimal capSize = quoteProgram.Pricing_Exception_Quota__c;
                             creationAllowed = (quoteProgram.Pricing_Exception_Quota__c <= qTypeToNoOfQuotesMap.get(quoteProgram.Pricing_Quote_Type__c+':'+quoteProgram.Pricing_Account__c)) ? 'false:'+capSize+':'+(capSize-qTypeToNoOfQuotesMap.get(quoteProgram.Pricing_Quote_Type__c+':'+quoteProgram.Pricing_Account__c)) : 'true:'+capSize+':'+(capSize-qTypeToNoOfQuotesMap.get(quoteProgram.Pricing_Quote_Type__c+':'+quoteProgram.Pricing_Account__c));
                             svdCreationAllowed.put(quoteProgram.Pricing_Quote_Type__c,creationAllowed);
                         }
                         if(isDataCenterClientQuoteAPI && quoteProgram.Pricing_Active_cb__c == true && (qTypeToNoOfQuotesMap.isEmpty() || !qTypeToNoOfQuotesMap.containskey(quoteProgram.Pricing_Quote_Type__c+':'+quoteProgram.Pricing_Account__c)) ){
                             Decimal capSize = quoteProgram.Pricing_Exception_Quota__c;
                             creationAllowed = 'false:'+capSize+':'+capSize;
                             svdCreationAllowed.put(quoteProgram.Pricing_Quote_Type__c,creationAllowed);
                         }
                     }
                 } 
                 return svdCreationAllowed;   
             }else {
                 return null;
             }
        }
        catch(exception ex){
             Pricing_Tender_Utility.logError(ex);
             return null;
        }
        
    }
 
    @AuraEnabled
    public static List<QuoteTypeWrapper> getQuoteTypes(String quoteTypeJSON ,String accId) {
        List<QuoteTypeWrapper> quoteTypeObjList = (List<QuoteTypeWrapper>)JSON.deserialize(quoteTypeJSON, List<QuoteTypeWrapper>.class);
        String remainingQuotes = '';
        String remainingClientQuotes = '';
        String remainingDataCenterQuotes ='';
        if(accId!=null || quoteTypeJSON!=null){
            if(TriggerHandler.isActive('Pricing_SVD_Quote_Disabled') || isTestRunning){
                            Integer countInCurrentQuarter = getcountOfQuotesInQuarter(accId);
                            List<Pricing_QuoteProgram_CAPSize__c> quoteProgram = getcapSizeOfAccountSVD(accId);
                            
                            if(quoteProgram.size() > 0) {
                                if(quoteProgram[0].Pricing_Active_cb__c == true) {
                                    Integer capSize = (quoteProgram[0].Pricing_Small_Deal_CAP_size_Number__c).intValue();
                                    remainingQuotes = String.valueOf(capSize - countInCurrentQuarter);  
                                } 
                            }       
            }
            Set<String> accountIdSet = new Set<String>{accId};
            Map<String, Integer> countInCurrentQuarterMap = getcountOfQuotesInQuarters(accountIdSet);
            List<Pricing_Systematic_Tender_Limitation__c> quoteProgram = getcapSizeOfAccount(accountIdSet);
            if(quoteProgram.size() > 0) {
                for(Pricing_Systematic_Tender_Limitation__c quotetypes : quoteProgram){
                    if(quotetypes.Pricing_Active_cb__c){
                            Integer capSize = (quotetypes.Pricing_Exception_Quota__c).intValue();
                            if(quotetypes.Pricing_Quote_Type__c == Label.Pricing_Tender_Standard_Quote){
                                remainingDataCenterQuotes = String.valueOf(capSize - countInCurrentQuarterMap.get(quotetypes.Pricing_Quote_Type__c+':'+quotetypes.Pricing_Account__c));
                            }
                            else if(quotetypes.Pricing_Quote_Type__c  == Label.Pricing_Tender_CCG_Quote){
                                remainingClientQuotes = String.valueOf(capSize - countInCurrentQuarterMap.get(quotetypes.Pricing_Quote_Type__c+':'+quotetypes.Pricing_Account__c));
                            }
                        }        
                } 
            }    
            
            
            for(QuoteTypeWrapper quoteType: quoteTypeObjList){
                if(quoteType.label == Label.Pricing_Tender_CCG_Quote){
                    String msg = ' '+ Label.Pricing_CCG_DataCenter_Remaining_Quote_Cap_Size_Message +' ';
                    if(remainingClientQuotes!=null && remainingClientQuotes!='' ){
                        Integer remQuoteClientInt = Integer.valueOf(remainingClientQuotes.trim());
                        if(remQuoteClientInt >= 0 &&  remQuoteClientInt <= 5 ){
                            quoteType.message= '(' + remainingClientQuotes + msg;
                            quoteType.color = 'red';
                        } else if(remQuoteClientInt > 5){
                            quoteType.message= '(' + remainingClientQuotes + msg;
                            quoteType.color = 'blue';
                        } else{
                            quoteType.message= '(0' + msg ;
                            quoteType.color = 'red';
                        }
                  
                    }
                    quoteType.checked = false;

                } else if(quoteType.label == Label.Pricing_Tender_Small_Volume_Quote){
                    String msg = ' '+ Label.Pricing_SVD_Remaining_Quote_Cap_Size_Message+' ';
                    if(remainingQuotes!=null && remainingQuotes!='' ){
                        Integer remQuoteInt = Integer.valueOf(remainingQuotes.trim());
                        if(remQuoteInt >= 0 &&  remQuoteInt <= 5 ){
                            quoteType.message= msg + remainingQuotes +')';
                            quoteType.color = 'red';
                        } else if(remQuoteInt > 5){
                            quoteType.message= msg + remainingQuotes +')';
                            quoteType.color = 'blue';
                        } else{
                            quoteType.message= msg + '0)';
                            quoteType.color = 'red';
                        }              
                    }
                    quoteType.checked = false;
                    
                } else {
                    String msg = ' '+ Label.Pricing_CCG_DataCenter_Remaining_Quote_Cap_Size_Message+' ';
                    if(remainingDataCenterQuotes!=null && remainingDataCenterQuotes!='' ){
                        Integer remDataCenterQuoteInt = Integer.valueOf(remainingDataCenterQuotes.trim());
                        if(remDataCenterQuoteInt >= 0 &&  remDataCenterQuoteInt <= 5 ){
                            quoteType.message= '(' + remainingDataCenterQuotes + msg;
                            quoteType.color = 'red';
                        } else if(remDataCenterQuoteInt > 5){
                            quoteType.message= '(' + remainingDataCenterQuotes + msg;
                            quoteType.color = 'blue';
                        } else{
                            quoteType.message= '(0' + msg ;
                            quoteType.color = 'red';
                        }               
                    }
                    quoteType.checked = false;
                }
            }
            return quoteTypeObjList;
        } else{
            return null;
        }
        
    }
    
    //Method to return the total count of SVD Quotes created for the particular account
    public static Map<String,Integer> getcountOfQuotesInQuarters (Set<String> accId) {
        Map<String,Integer> qTypeToNoOfQuotesMap = new Map<String,Integer>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id,Pricing_Program_Type_Nm__c,SBQQ__Account__c FROM SBQQ__Quote__c WHERE Pricing_Program_Type_Nm__c IN: Label.Pricing_QuoteTypes.split(',')
                                          AND CreatedDate = THIS_QUARTER AND SBQQ__Account__c =: accId AND Pricing_Volume_Exception_Quota_Cb__c =: true AND Pricing_Exclude_from_Volume_Excep_Quota__c = false
                                          AND SBQQ__Status__c IN: Label.Pricing_QuoteStatus_AllPicklistValues_Except_Rejected.split(',')];
       // Integer svdCount = 0;
        Integer clientCount = 0;
        Integer cpuCount = 0;
        for(SBQQ__Quote__c quote : quoteList){
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote){
                clientCount++;
                qTypeToNoOfQuotesMap.put(quote.Pricing_Program_Type_Nm__c+':'+quote.SBQQ__Account__c,clientCount);
            }else if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote){
                cpuCount++;
                qTypeToNoOfQuotesMap.put(quote.Pricing_Program_Type_Nm__c+':'+quote.SBQQ__Account__c,cpuCount);
            }
        }
        if(quoteList.isEmpty() || qTypeToNoOfQuotesMap.size() > 0){
            String firstaccountId ;
            for(String accountId: accId){
                firstaccountId = accountId;
                break;
            }
            if(!qTypeToNoOfQuotesMap.containsKey(Label.Pricing_Tender_CCG_Quote+':'+firstaccountId)){
            qTypeToNoOfQuotesMap.put(Label.Pricing_Tender_CCG_Quote+':'+firstaccountId,0);
            }
            if(!qTypeToNoOfQuotesMap.containsKey(Label.Pricing_Tender_Standard_Quote+':'+firstaccountId)){
            qTypeToNoOfQuotesMap.put(Label.Pricing_Tender_Standard_Quote+':'+firstaccountId,0);
            }
        }
        return qTypeToNoOfQuotesMap;
    }

    ////Method to return the total count of SVD Quotes created for the particular account
    private static Integer getcountOfQuotesInQuarter (String accId) {
        List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c WHERE Pricing_Program_Type_Nm__c =: Label.Pricing_Tender_Small_Volume_Quote 
                                          AND CreatedDate = THIS_QUARTER AND SBQQ__Account__c =: accId AND SBQQ__Status__c IN: Label.Pricing_QuoteStatus_AllPicklistValues_Except_Rejected.split(',')];
        integer countInCurrentQuarter = quoteList.size();
        return countInCurrentQuarter;
    }

	//Method to return quote program cap size of Account
    private static List<Pricing_Systematic_Tender_Limitation__c> getcapSizeOfAccount (Set<String> accId) {
         List<Pricing_Systematic_Tender_Limitation__c> quoteProgram = [SELECT Id,Pricing_Active_cb__c,Pricing_Quote_Type__c,Pricing_Account__c,Pricing_Exception_Quota__c 
                                                            FROM Pricing_Systematic_Tender_Limitation__c WHERE Pricing_Account__c =: accId];
        return quoteProgram;
    }

    //Method to return quote program cap size of Account SVD
    private static List<Pricing_QuoteProgram_CAPSize__c> getcapSizeOfAccountSVD (String accId) {
        List<Pricing_QuoteProgram_CAPSize__c> quoteProgram = [SELECT Id,Pricing_Active_cb__c,Pricing_Account_Id__c,Pricing_Small_Deal_CAP_size_Number__c 
                                                           FROM Pricing_QuoteProgram_CAPSize__c WHERE Pricing_Account_Id__c =: accId limit 1];
       return quoteProgram;
   }
    
    //Wrapper class to return Quote Type label, message and message color on UI New Quote Button
    public class QuoteTypeWrapper{
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String message {get;set;}
        @AuraEnabled       
        public String color {get;set;}
        @AuraEnabled
        public Boolean checked {get;set;}        
    }

    /**
    * @description :  Return boolean for SVD Quote is active or not
    * @author Vrushabh Uprikar | 01-06-2025 
    * @return boolean 
    **/
    @AuraEnabled(cacheable=true)
    public static boolean getSVDQuoteActiveStatus(){
        integer count = [Select COUNT() From Trigger_Execution__mdt Where DeveloperName = 'Pricing_SVD_Quote_Disabled' AND Active__c = true limit 1];
        return count > 0 ? true : false;
    }
}