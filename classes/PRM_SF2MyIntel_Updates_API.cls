/*******************************************************************************************************************************
Apex Class Name  : PRM_SF2MyIntel_Updates_API
Version       : 1.0
Created Date  : DEC 2021
Function      : API for SF to MyIntel Updates

Modification Log :
* Developer                				 Date               Description
* ----------------------------------------------------------------------------------------------------------------------------------------------
* Gopikrishna Vankadari            	    15/12/2021         API for SF to MyIntel Updates
************************************************************************************************************************************************/
@RestResource(urlMapping='/SF2myIntel/Updates')
global class PRM_SF2MyIntel_Updates_API {   
    public static final String LOG_ENTRY_ORIGIN 	 = 'SF2myIntel';
    public static final String LOG_ENTRY_PROJECT 	 = 'SF2myIntel';
    public static final String LOG_ENTRY_SCOPE   	 = 'SF2myIntel API';
    public static final String LOG_ENTRY_ERROR    	 = 'error';
    public static final String LOG_ENTRY_INFO     	 = 'info';
    @HttpPost
    global static void processMyIntelUpdates(){        
        String jsonInput = RestContext.request.requestBody.toString(); 
        //Log the Input Payload
        Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_INFO,'Input PayLoad',jsonInput,null,null,null);
        String returnMessage;
        PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails InputDetailsParser; 
        List<PRM_SF2MyIntel_Updates_API_Utility.composeCommunityDetails> inputDataList = new List<PRM_SF2MyIntel_Updates_API_Utility.composeCommunityDetails>();        
       // Map<String,Contact> emailContactMap = new Map<String,Contact>();
       // Set<String> communitesOptedIn  = new Set<String>();
       // Set<String> communitesOptedOut = new Set<String>();         
        
        //Communities Available for Onboarding
        Set<String> communitiesAvailable = new Set<String>();
        communitiesAvailable.addAll((System.Label.PRM_Available_Communities).split(';'));
      
        //deserialize JSON Input        
        InputDetailsParser=(PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails) JSON.deserialize(jsonInput, PRM_SF2MyIntel_Updates_API_Utility.FetchInputDetails.Class);
      
        inputDataList=InputDetailsParser.CommunityDetails;
        String InputEmail = InputDetailsParser.EmailId;        
        String attribute =InputDetailsParser.Attribute!=null?(String.IsEmpty(InputDetailsParser.Attribute)?null:InputDetailsParser.Attribute):null;
        
        SWITCH on attribute {               
            When 'GETCOMMUNITYOPTINS' {
                if(InputEmail==null ||String.isEmpty(InputEmail)){                   
                    returnMessage = PRM_SF2MyIntel_Updates_API_Utility.INCORRECT_EMAIL;
                    Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_ERROR,returnMessage,jsonInput,null,null,InputEmail);
                    PRM_SF2MyIntel_Updates_API_Utility.responseDetails(returnMessage,false);
                }else{                        
                    if(InputEmail!=null){
                        PRM_SF2MyIntel_Updates_API_Utility.retrieveCommunityDetails(InputEmail);                        
                    }                       
                }
            } 
            When 'MODIFYCOMMUNITYOPTINS' {
                if(InputEmail!=null && inputDataList!=null && !inputDataList.isEmpty()){
                    PRM_SF2MyIntel_Updates_API_Utility.updateCommunityDetails(InputEmail,inputDataList);
                    //createLogEntry('GetProfile API response log '+inputfield+': '+inputvalue+' Attribute: '+attribute+' AdditionalAttribute: '+addtlInputField+': '+addtlInputValue+ ' Response Time in MS: '+response.ResponseTimeMS, null, LOG_ENTRY_INFO,inputvalue );
                }else{                        
                    if(InputEmail!=null){
                        returnMessage = PRM_SF2MyIntel_Updates_API_Utility.MISSING_FIELDS;
                        Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_ERROR,returnMessage,jsonInput,null,null,InputEmail);
                        PRM_SF2MyIntel_Updates_API_Utility.responseDetails(returnMessage,false);                        
                    }                       
                }
            }
            WHEN null {
                returnMessage = PRM_SF2MyIntel_Updates_API_Utility.INVALID_FIELDS;
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_ERROR,returnMessage,jsonInput,null,null,InputEmail);
                PRM_SF2MyIntel_Updates_API_Utility.responseDetails(returnMessage,false);  
            }               
        }// End of SWITCH  
    }   
}