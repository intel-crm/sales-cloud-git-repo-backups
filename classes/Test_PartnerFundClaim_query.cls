public class Test_PartnerFundClaim_query {
    public static Map<Id,PartnerFundClaim> claimMap;

    public static void PartnerFundClaimcheck(){
        Map<String,String> myMap=new Map<String,String>();

        for(CCP_Activity_Type_dependent_fields__mdt obj:([Select Core_MDF_Object_API_Field_Name__c, DeveloperName  from CCP_Activity_Type_dependent_fields__mdt where Core_MDF_Module__c = 'PartnerFundClaim'])){
            
            Boolean contains = myMap.containsKey(obj.Core_MDF_Object_API_Field_Name__c);
                    if(contains!=true){
                     myMap.put(obj.Core_MDF_Object_API_Field_Name__c,obj.DeveloperName);
            //system.debug(obj);
        		}
        }
        
        Set <String> APIKey = new Set<String>();
		APIKey = myMap.keySet();

        
        List<String> lStrings = new List<String>(APIKey);
        //CCP_Activity_Type_dependent_fields__mdt obj2=new CCP_Activity_Type_dependent_fields__mdt();
       
       string allstring = string.join(lStrings,',');
        
        String  query = 'SELECT Id,Title,Request.Title,Request.Core_MDF_Activity_Number__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_AccountCompany__c,Core_MDF_Claim_Ref_Number__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_VAT_Opt_In__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Country_Location_nm__c,Core_MDF_Ad_Run_End_Date__c, Core_MDF_Media_Vehicle__c,Core_MDF_Invoice_Date__c,Core_MDF_Bank__r.Name,RecordTypeId,';
        

		query += allstring;
        query+=' FROM PartnerFundClaim WHERE Id IN :claimIdSet';
        list<PartnerFundClaim> lst1=new list<PartnerFundClaim>();
        map<Id,PartnerFundClaim> claimMap = new Map<id,PartnerFundClaim>();
       lst1= Database.query(query);
        for(PartnerFundClaim pcf1:lst1){
            claimMap.put(pcf1.id,pcf1);
        }
        

    }
    
    
}