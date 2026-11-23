public without sharing class Core_MDF_CloseActivity {
    

/****************************************************************************************************** 
Class Name:         activityCloseWrapper
@parameters:        N/A
Description:        Wrapper which will hold return values of all the validation check to close activity
Added By:           Sridhar   04-08-2019
Modified By:        Date:      Changes: 
Nuzhath				11-3-2019		Added an attribute for retail program
*******************************************************************************************************/
	public class activityCloseWrapper{   	
        @AuraEnabled
        public boolean isValidActivity=false;
		@AuraEnabled
        public boolean hasActiveClaims=false;
        @AuraEnabled
        public List<PartnerFundClaim> listOfClaim = new List<PartnerFundClaim>();
        @AuraEnabled
        public boolean isValidActStatus=true;
        @AuraEnabled
        public boolean activityNotStarted=false;
        @AuraEnabled
        public boolean retailActivity = false;
    }


/****************************************************************************************************** 
Method Name:        userEligibilitytoIncloseActivity
@return  :          Boolean whether the user has permission or not.
@parameters:        Allowed permission sets
Description:        This method is used to check if user has permission to close the activity.
Added By:           Sridhar - 03/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/  
    @AuraEnabled
    Public static Boolean userEligibilitytoIncloseActivity(Map<string,List<string>> permissionsets){
        Boolean eligibleUser=false;
        Core_MDF_PartnerFundRequestCreatePage.userPermissionSetWrapper permissionWrapper = new Core_MDF_PartnerFundRequestCreatePage.userPermissionSetWrapper();
        Map<string,boolean> perMap = new Map<string,boolean>();

        try {
            
            permissionWrapper = Core_MDF_PartnerFundRequestCreatePage.userHasPermissionSet(permissionsets);
            perMap = permissionWrapper.userPermissions;
			            
            if (perMap != null)
            {
                for(string key : perMap.keySet())
                {
                    if (perMap.get(key) == true)
                    {
                        eligibleUser = true;
                        break;
                    }
                }
            }
            
            //return eligibleUser;
        } 
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        return eligibleUser;
    }

/****************************************************************************************************** 
Method Name:        checkActivityEligibiltyForClose
@return  :          activityCloseWrapper
@parameters:        Activity Id
Description:        This method will call other methods to check for different validations
Added By:           Sridhar - 03/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
	@AuraEnabled
    public  static activityCloseWrapper checkActivityEligibiltyForClose (Id activityId ){
        
        activityCloseWrapper actWrap  = new activityCloseWrapper();
        activityCloseWrapper claimActWrap = new activityCloseWrapper();
        PartnerFundRequest activity = NULL;

	 	try{
            
            activity = [SELECT Id, Core_MDF_Start_Date__c, Core_MDF_Fund_Request_Status__c,Core_MDF_Program__c FROM PartnerFundRequest WHERE Id =: activityId LIMIT 1];

            String actNotAllowedStatus = System.label.Core_MDF_Close_Activity_NotAllowed_ActStatus;
            List<String> actNotAllowedStatusList = new List<String>();
            actNotAllowedStatusList = actNotAllowedStatus.split(',');
			
            if (activity != null)
            {
              if(!actNotAllowedStatus.contains(activity.Core_MDF_Fund_Request_Status__c) || (activity.Core_MDF_Fund_Request_Status__c == 'Revision Required' && activity.Core_MDF_Program__c == 'Retail Marketing Funds'))
              {
               // if (!actNotAllowedStatus.contains(activity.Core_MDF_Fund_Request_Status__c))
                //{
                 
          			  if (!(activity.Core_MDF_Start_Date__c > Date.Today()))
                    {
                        claimActWrap = checkClaims(activityId);
                        actWrap.hasActiveClaims = claimActWrap.hasActiveClaims;
                        actWrap.listOfClaim = claimActWrap.listOfClaim.clone();
                        actWrap.isValidActivity = true;

                        //When activity is valid to close, activity status field will be updated
                        if(actWrap != null && !actWrap.hasActiveClaims)
                        {
                            activity.Core_MDF_Fund_Request_Status__c = 'Closed';
                            activity.Core_MDF_ToBeClosedDate__c = System.today();
                            Database.update (activity);
                        }
                  //  }
                    }
                    else
                    {
                        actWrap.activityNotStarted = true;
                    }
                   
                }
               
                else
                {
                    actWrap.isValidActStatus = false;actWrap.retailActivity = activity.Core_MDF_Program__c == 'Retail Marketing Funds' ? true : false;
                }
            }
        }
		
		catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;//throw new AuraHandledException(e.getMessage());
            }

        return actWrap; 
	}

/****************************************************************************************************** 
Method Name:        checkClaims
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        N/A
Description:        This method is used to check claims associated with this activity which doesn't have end status.
Added By:           Sridhar   10/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    Public static activityCloseWrapper checkClaims (Id activityId){
        	activityCloseWrapper checkClaimWrapper = new activityCloseWrapper ();
            
            //Fetch claim status from custom label
            String claimStatusList = System.label.Core_MDF_Claim_Status_For_Account_Inactive;
        	list<String> claimStatusSet = new list<String>();
        	
        	if(!String.IsBlank(claimStatusList)){
            	claimStatusSet = claimStatusList.split(';');
        	}
		
            //List to store the claims which are in submitted, hold, pending available funds, payment due and pending payment status
            //System.debug('***claimStatusSet' + claimStatusSet);
            //System.debug('***activityId' + activityId);
            List<PartnerFundClaim> claimList = [SELECT Id FROM PartnerFundClaim WHERE RequestId =:activityId and Core_MDF_Status__c  IN:claimStatusSet];		
        	if (claimList != Null && claimList.size()>0 ){
            	checkClaimWrapper.hasActiveClaims = true;
            	checkClaimWrapper.listOfClaim = claimList.clone();
            }
			return checkClaimWrapper;
    } 

}