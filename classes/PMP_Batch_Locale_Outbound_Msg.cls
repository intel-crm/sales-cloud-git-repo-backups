/****************************************************************************************************************************************
* Class Name        : PMP_Batch_Locale_Outbound_Msg
* Created Date      : 07-29-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar       07-29-2019          Batch class to send out the locale information to GLS team.
*****************************************************************************************************************************************/
//IPA2.0 - As part of TWC729-7977 commented the entire class & added dummy syntax to override error
public without sharing class PMP_Batch_Locale_Outbound_Msg implements Database.Batchable<sObject>, Database.Stateful 
{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // added dummy syntax to override error
       return null;
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        // added dummy syntax to override error
    }

    public void finish(Database.BatchableContext bc) {
        // added dummy syntax to override error
    }
    /*
	public list<PMP_Partner_Offering__c> offerings = new list<PMP_Partner_Offering__c>();
    // Map to store the language code, and List of offerings
    public Map<string,List<PMP_Partner_Offering__c>> offeringsMap = new Map<string,List<PMP_Partner_Offering__c>>();
    public string queryLimit = '50';
    
    // Batch constructors
    public PMP_Batch_Locale_Outbound_Msg () {}
    public PMP_Batch_Locale_Outbound_Msg (string queryLimit) {
        if (queryLimit != null)
        {
        	this.queryLimit = queryLimit;    
        }
    }
    
     // Batch start method
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        string queryString = null;
        try
        {
        	queryString = 'Select Id, Name, PMP_Partner_Offering_Nm__c, PMP_Partner_Offering_Dsc__c,' 
                              + 'PMP_Partner_Offering_Tag_Line_Txt__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c,'
            				  + 'PMP_Translation_Lifecycle_Status_nm__c,PMP_Offering_Language_Nm__c,lastmodifieddate'
            				  + ' FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'' + String.escapeSingleQuotes('Approved') + '\''
            				  + ' and PMP_Translation_Lifecycle_Status_nm__c =\'' + String.escapeSingleQuotes('Pending') +'\''
            				  + ' and PMP_Offering_language_Nm__c != null'
            				  + ' LIMIT ' + this.queryLimit ;
        
        }catch(Exception e){
            // system.debug('Error occured from class PMP_Batch_Locale_Outbound_Msg start method due to '+ e.getCause());
            }
        
        return Database.getQueryLocator(queryString);        
    }
    
    // Batch execute method
    public void execute(Database.BatchableContext bc, List<PMP_Partner_Offering__c> scope) {        
        
        List<Core_Integration_Outbound_Message__c> outBoundJson = new List<Core_Integration_Outbound_Message__c>();
    	// Map to store the language name and code
        Map<string,string> languages = new Map<string,string>();
        boolean isSuccess = false;
        
        try
        {
             // Read language supported meta data values
            for (PMP_Languages__mdt lngsSupported : [select Locale_Nm__c,Language_Code__c from PMP_Languages__mdt where Locale_Nm__c != null])
            {
                 languages.put(lngsSupported.Locale_Nm__c, lngsSupported.Language_Code__c);
            }
            
            // Loop the list of offerings and group them by language code
            for (PMP_Partner_Offering__c offering : scope)
            {
                string sourcelangcode = languages.get(offering.PMP_Offering_Language_Nm__c);
             
                // Set the status as In Progress to update the offerings
                offering.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
                offerings.add(offering);
                
                if (offeringsMap.containsKey(sourcelangcode))
                {
                    offeringsMap.get(sourcelangcode).add(offering);
                }
                else
                {
                    offeringsMap.put(sourcelangcode, new List<PMP_Partner_Offering__c> {offering});
                }
               
            }
            
           List<WrapOfferingMain> wrapperofferingslist = BuildOfferings(languages,offeringsMap);
           //system.debug('wrapperofferingslist->' + wrapperofferingslist);
           
           for (WrapOfferingMain wrapperofferings : wrapperofferingslist)
           {
                if (wrapperofferings != null && wrapperofferings.Offerings.size() > 0)
           		{
                   string outBoundJsonstr = JSON.serialize(wrapperofferings)
                                        .replace('SourceLanguage','Source Language')
                                        .replace('OfferingId','Offering Id')
                                        .replace('OfferingName','Offering Name')
                                        .replace('OfferingDescription','Offering Description')
                                        .replace('TargetLanguage','Target Language');
                        
                   Core_Integration_Outbound_Message__c oBMsg = new Core_Integration_Outbound_Message__c();
                   oBMsg.Core_MessageType__c = 'Marketplace Translation';
                   oBMsg.Core_Payload__c = outBoundJsonstr;
                   oBMsg.Core_Tags__c = 'Marketplace, Translation, offering';
                   
                   outBoundJson.add(oBMsg);
                   
           		}
           }
            
          	//system.debug('offerings->' + offerings.size());
            if (outBoundJson.size() > 0 && offerings.size() > 0)
            {
                Insert outBoundJson;
                update offerings;
                
                isSuccess = true;
            }
        
        }
        catch(Exception e){
            //system.debug('Error occured from class PMP_Batch_Locale_Outbound_Msg execute method due to '+ e.getCause());
        }
    }
    
    // Batch finish method
    public void finish(Database.BatchableContext bc) {
        
    }
    
    public List<WrapOfferingMain> BuildOfferings(Map<string,string> languages,Map<string,List<PMP_Partner_Offering__c>> offeringsMap)
    {
        List<WrapOfferingMain> offeringMainList = new List<WrapOfferingMain>();

        for (String sourceLanguage : languages.values()) {
            List<WrapOfferings> offeringsList = buildOfferingsList(sourceLanguage, languages, offeringsMap);

            WrapOfferingMain offeringMain = new WrapOfferingMain();
            offeringMain.SourceLanguage = sourceLanguage;
            offeringMain.Offerings = offeringsList;
            offeringMainList.add(offeringMain);
        }

        return offeringMainList;
    }

    private List<WrapOfferings> buildOfferingsList(String sourceLanguage, Map<String, String> languages, Map<String, List<PMP_Partner_Offering__c>> offeringsMap) {
        List<WrapOfferings> offeringsList = new List<WrapOfferings>();

        List<PMP_Partner_Offering__c> sourceLanguageOfferings = offeringsMap.get(sourceLanguage);

        if (sourceLanguageOfferings != null) {
            for (PMP_Partner_Offering__c offering : sourceLanguageOfferings) {
                offeringsList.addAll(buildOfferingForTargetLanguages(offering, sourceLanguage, languages));
            }
        }

        return offeringsList;
    }

    private List<WrapOfferings> buildOfferingForTargetLanguages(PMP_Partner_Offering__c offering, String sourceLanguage, Map<String, String> languages) {
        List<WrapOfferings> offeringsList = new List<WrapOfferings>();

        for (String targetLanguage : languages.values()) {
            if (!targetLanguage.equals(sourceLanguage)) {
                WrapOfferings wrapOffering = new WrapOfferings();
                wrapOffering.OfferingId = offering.Id;
                wrapOffering.OfferingName = offering.PMP_Partner_Offering_Nm__c;
                wrapOffering.OfferingDescription = offering.PMP_Partner_Offering_Dsc__c;
                wrapOffering.TagLine = offering.PMP_Partner_Offering_Tag_Line_Txt__c;
                wrapOffering.TargetLanguage = targetLanguage;
                wrapOffering.SentDate = Date.newInstance(
                    offering.LastModifiedDate.year(),
                    offering.LastModifiedDate.month(),
                    offering.LastModifiedDate.day()
                );

                offeringsList.add(wrapOffering);
            }
        }

        return offeringsList;
    }

   
    public class WrapOfferingMain 
  	{
        public String SourceLanguage {get; set;}
        public List<WrapOfferings> Offerings {get; set;}
    }   
    
    public class WrapOfferings
    {
        public String OfferingId {get; set;}
        public String OfferingName {get; set;}
        public String OfferingDescription {get; set;}
        public String TagLine {get; set;}
        public String TargetLanguage {get; set;}
        public Date SentDate {get; set;}
    }*/
}