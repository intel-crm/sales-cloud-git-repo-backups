/****************************************************************************************************************************************
* Class Name            : Core_MDF_PartnerFundAllocation 
 * Version              : 1.0 
* Created Date          : 16-JUNE-2021
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - TS      16-06-2021        It is used as a controller class for LWC which displays allocation information for External users    
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PartnerFundAllocation {
    
    /***************************************************************************************************** 
    Method Name:        getAllocationDetails
    @return  :          List<AllocationWrapper> allocationWrapperList
    Description:        This method is used to return allocation details as per the account node access for the logged in user
    @Added By:          Accenture - TS - 16-JUNE-2021
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static List<AllocationWrapper> getAllocationDetails(Map<String, Object> requestParams) {
        
        // Extract parameters from Map with default values and null safety
        Integer offsetCount = requestParams.containsKey('offsetCount') && requestParams.get('offsetCount') != null ? 
                             (Integer)requestParams.get('offsetCount') : 0;
        String sortField = requestParams.containsKey('sortField') && requestParams.get('sortField') != null ? 
                          (String)requestParams.get('sortField') : '';
        String direction = requestParams.containsKey('direction') && requestParams.get('direction') != null ? 
                          (String)requestParams.get('direction') : '';
        Boolean totalRecords = requestParams.containsKey('totalRecords') && requestParams.get('totalRecords') != null ? 
                              (Boolean)requestParams.get('totalRecords') : false;
        List<String> budgetTypeList = requestParams.containsKey('budgetTypeList') && requestParams.get('budgetTypeList') != null ? 
                                     (List<String>)requestParams.get('budgetTypeList') : new List<String>();
        List<String> programList = requestParams.containsKey('programList') && requestParams.get('programList') != null ? 
                                  (List<String>)requestParams.get('programList') : new List<String>();

        List<AllocationWrapper> allocationWrapperList = new List<AllocationWrapper>();
        Set<Id> accIds= new Set<Id>();
        List<String> budgetTypes = new List<String>();
        List<String> programs = new List<String>();
        Integer limitCount =Integer.valueOf(Label.Core_MDF_ClaimSelectionForAuditBatchSize); //current value is 50
        
        //Get logged in user id 
        Id loggedInUser = UserInfo.getUserId();
        //Check if logged in user has custom permission
        String allocationPermission=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_View_Allocation_Tab');
        Boolean hasPermission = FeatureManagement.checkPermission(allocationPermission);
        
        if(hasPermission){
            //Get the Accounts associated with the logged in user through Account User records
            for(Core_MDF_Partner_Node_User_Mapping__c pnum :[Select id,Core_MDF_Account__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c =:loggedInUser AND Core_MDF_Active_Ind__c = true]){
                if(pnum.Core_MDF_Account__c!=null){
                    accIds.add(pnum.Core_MDF_Account__c);
                }
            }
         
            //Getting allocation records as per logged in user account access
            String query = 'Select id,Budget.StartDate, Budget.EndDate,Amount,ChannelPartner.name,ChannelPartnerId,toLabel(Budget.Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c),toLabel(Budget.Core_MDF_Budget_Type_Txt__c),Core_MDF_Available_Allocation_Amount__c,Core_MDF_Total_Activity_Allocated_Amount__c, Core_MDF_Available_Activity_Alloc_Amt__c,Core_MDF_Claim_Reserved_Amount_Amt__c  from PartnerFundAllocation where ChannelPartnerId IN: accIds';
            
            if(accIds.size()>0 && !accIds.isEmpty() && budgetTypeList!=null && budgetTypeList.size()>0){
                 for(String budgetType : budgetTypeList){
                    String bdgt = budgetType.replace('"','');
                    budgetTypes.add(getAPINameOfSelectedBudgetType(bdgt));
                }
                query+= ' and Budget.Core_MDF_Budget_Type_Txt__c IN:budgetTypes';
             }
             
             if(accIds.size()>0 && !accIds.isEmpty() && programList!=null && programList.size()>0){
                for(String program : programList){
                    String prg = program.replace('"','');
                    programs.add(getAPINameOfSelectedProgram(prg));
                }
                query+=' and Budget.Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c IN:programs';
              }
              
            if(accIds.size()>0 && !accIds.isEmpty() && sortField != Null && sortField !='' && direction != Null && direction !=''){
                sortField = sortField.replace('"','');
                sortField = getSortFieldApiName(sortField); //Returns the api name of selected sort field
                direction = direction.replace('"','');
                query = query + ' Order by '+ sortField + ' ' + direction;
             } 
             
             if(accIds.size()>0 && !accIds.isEmpty() && !totalRecords){
                query += ' Limit :limitCount Offset :offsetCount'; //On loading more data
             }
             
             if(accIds.size()>0 && !accIds.isEmpty()){
                 for(PartnerFundAllocation pfa : Database.query(String.escapeSingleQuotes(query))){
                    String accountUrl = Label.Core_MDF_PFRCommunityLink+pfa.ChannelPartnerId;
                    AllocationWrapper allocWrap = new AllocationWrapper();
                    allocWrap.accountName = pfa.ChannelPartner.name;
                    allocWrap.accountURL = accountUrl;
                    allocWrap.programName = pfa.Budget.Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c;
                    allocWrap.budgetType = pfa.Budget.Core_MDF_Budget_Type_Txt__c;
                    allocWrap.startDate = pfa.Budget.StartDate;
                    allocWrap.endDate = pfa.Budget.EndDate ;
                    allocWrap.amount = pfa.Amount;
                    allocWrap.activityReservedAmount = pfa.Core_MDF_Total_Activity_Allocated_Amount__c;
                    allocWrap.activityAvailableAmount = pfa.Core_MDF_Available_Activity_Alloc_Amt__c;
                    allocWrap.claimReservedAmount = pfa.Core_MDF_Claim_Reserved_Amount_Amt__c;
                    allocWrap.claimAvailableAmount = pfa.Core_MDF_Available_Allocation_Amount__c ;
                    allocationWrapperList.add(allocWrap);
                }
            }
        }
        return allocationWrapperList;
    }

    /***************************************************************************************************** 
    Method Name:        getAPINameOfProgram
    @return  :          String selectedAPIName
    Description:        This method is used to return selected program API name  
    @Added By:          Accenture - TS - 16-JUNE-2021
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    public static String getAPINameOfSelectedProgram(String selectedProgLabel){
        String selectedAPIName='';
        Schema.DescribeFieldResult fieldResult = ChannelProgram.Core_MDF_Technical_Program_Name__c.getDescribe();
        List<Schema.PicklistEntry> programValues = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry eachProgramVal : programValues){
                if(selectedProgLabel == eachProgramVal.getLabel()){
                        selectedAPIName= eachProgramVal.getValue();
                        break;
                }
            }    
        
        return selectedAPIName;
    }
    
    /***************************************************************************************************** 
    Method Name:        getAPINameOfSelectedBudgetType
    @return  :          String selectedAPIName
    Description:        This method is used to return selected budget type API name. 
    @Added By:          Accenture - TS - 16-JUNE-2021
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    public static String getAPINameOfSelectedBudgetType(String selectedBudgType){
        String selectedAPIName='';
        Schema.DescribeFieldResult fieldResult = PartnerMarketingBudget.Core_MDF_Budget_Type_Txt__c.getDescribe();
        List<Schema.PicklistEntry> programValues = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry eachProgramVal : programValues){
                if(selectedBudgType == eachProgramVal.getLabel()){
                        selectedAPIName= eachProgramVal.getValue();
                        break;
                }
            }    
        
        return selectedAPIName;
    }
    
    /***************************************************************************************************** 
    Method Name:        getFieldApiName
    @return  :          String sortFieldAPIName
    Description:        This method is used to return selected sort field's API name  
    @Added By:          Accenture - TS - 16-JUNE-2021
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    public static String getSortFieldApiName(String sortFieldName){
        String allFields = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFA_Fields');
        String sortFieldAPIName='';
        List<String> fieldsWithAPINames = allFields.split(',');
            for(String eachField : fieldsWithAPINames){
                String sortField = eachField.substringBefore('-');
                if(sortField == sortFieldName){
                    sortFieldAPIName=eachField.substringAfter('-'); 
                    break;
                    }
                }
        return sortFieldAPIName;
    }
    
    //Creating a Wrapper class which would be used to display data from allocation,budget and account objects
    public class AllocationWrapper{
            @AuraEnabled public String accountName {get;set;} //Account Name
            @AuraEnabled public String accountURL {get;set;}   //Used to make account name as hyperlink
            @AuraEnabled public String programName {get;set;} //Budget Program
            @AuraEnabled public String budgetType {get;set;}  //Budget Type
            @AuraEnabled public Decimal amount {get;set;}     // Total Allocated Amount of PFA
            @AuraEnabled public Decimal activityReservedAmount {get;set;} //Amount consumed by existing active activit
            @AuraEnabled public Decimal activityAvailableAmount {get;set;} // Amount available for Activity creation
            @AuraEnabled public Decimal claimReservedAmount {get;set;} //Amount consumed by existing Claims (Active only)
            @AuraEnabled public Decimal claimAvailableAmount {get;set;} //Amount available for Claim creation
            @AuraEnabled public Date startDate {get;set;} //Budget Start Date
            @AuraEnabled public Date endDate {get;set;} //Budget End Date
    } 
}