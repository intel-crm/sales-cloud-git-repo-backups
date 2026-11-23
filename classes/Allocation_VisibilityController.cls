/****************************************************************************************************************************************
* Class Name            : Core_MDF_PartnerFundAllocation 
 * Version              : 1.0 
* Created Date          : 16-JUNE-2021
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - TS      16-06-2021        It is used as a controller class for LWC which displays allocation information for External users    
*****************************************************************************************************************************************/
public without sharing class Allocation_VisibilityController {
    /***************************************************************************************************** 
    Method Name:        getAllocationDetails
    @return  :          List<AllocationWrapper> allocationWrapperList
    Description:        This method is used to return allocation details as per the account node access for the logged in user
    @Added By:          Accenture - TS - 16-JUNE-2021
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
        @AuraEnabled(cacheable=true)
        public static List<AllocationWrapper> getAllocationDetails(Integer offsetCount , String sortField , String direction) {
            List<AllocationWrapper> allocationWrapperList = new List<AllocationWrapper>();
            Set<Id> accIds= new Set<Id>();
            Integer limitCount = 5;
            //Get logged in user id 
            Id loggedInUser = UserInfo.getUserId(); 
            System.debug('User Id@@@' +loggedInUser);
            System.debug('offsetCount----'+ offsetCount);
            System.debug('sortField-----'+sortField);
            System.debug('direction----'+direction);
            //Check if logged in user has custom permission
            Boolean hasPermission = FeatureManagement.checkPermission('Core_MDF_View_Custom_Allocation_Tab');
            if(hasPermission){
                //Get the Accounts associated with the logged in user through Account User records
                for(Core_MDF_Partner_Node_User_Mapping__c pnum :[Select id,Core_MDF_Account__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c =:loggedInUser]){
                    System.debug('Inside for loop of PNUM' +pnum.id);
                    if(pnum.Core_MDF_Account__c!=null){
                        accIds.add(pnum.Core_MDF_Account__c);
                    }
                }
                //Getting allocation records as per logged in user account access
                if(accIds.size()>0 && !accIds.isEmpty()){
                    String query = 'Select id,Title,Budget.StartDate, Budget.EndDate,Amount,ChannelPartner.name,ChannelPartnerId,Budget.Core_MDF_Program__r.name,toLabel(Budget.Core_MDF_Budget_Type__c),Core_MDF_Available_Allocation_Amount__c,Core_MDF_Total_Activity_Allocated_Amount__c, Core_MDF_Available_Activity_Alloc_Amt__c,TotalApprovedFcs  from PartnerFundAllocation where ChannelPartnerId IN: accIds';
                    query += ' and Budget.Core_MDF_Budget_Type__c!=null';
                    
                    if(sortField != Null && sortField !='' && direction != Null && direction !=''){
                       sortField = sortField.replace('"','');
                        switch on sortField{
                           when 'accountURL'{
                                sortField = 'ChannelPartner.name';
                            }
                            when 'programName'{
                                sortField = 'Budget.Core_MDF_Program__r.name';
                            }
                            when 'budgetType'{
                                sortField = 'Budget.Core_MDF_Budget_Type__c';
                            }
                            when 'startDate'{
                                sortField = 'Budget.StartDate';
                            }
                            when 'endDate'{
                                sortField = 'Budget.EndDate';
                            }
                            when 'amount'{
                                sortField = 'Amount';
                            }
                            when 'totalActivityAllocAmount'{
                                sortField = 'Core_MDF_Total_Activity_Allocated_Amount__c';
                            }
                            when 'unallocatedActAmount'{
                                sortField = 'Core_MDF_Available_Activity_Alloc_Amt__c';
                            }
                            when 'totalApprovedFundClaims'{
                                sortField = 'TotalApprovedFcs';
                            }
                            when 'unallocatedClaimAmount'{
                                sortField = 'Core_MDF_Available_Allocation_Amount__c';
                            }
                        } 
                        direction = direction.replace('"','');
                        query = query + ' Order by '+ sortField + ' ' + direction;
                    } 

                    query += ' Limit :limitCount Offset :offsetCount';
                    system.debug('query-------'+query);
                    //for(PartnerFundAllocation pfa : [Select id,Title,Budget.StartDate, Budget.EndDate,Amount,ChannelPartner.name,ChannelPartnerId,Budget.Core_MDF_Program__r.name,toLabel(Budget.Core_MDF_Budget_Type__c),Core_MDF_Available_Allocation_Amount__c,Core_MDF_Total_Activity_Allocated_Amount__c, Core_MDF_Available_Activity_Alloc_Amt__c,TotalApprovedFcs  from PartnerFundAllocation where ChannelPartnerId IN: accIds
                     //                               and Budget.Core_MDF_Budget_Type__c!=null Limit :limitCount Offset :offsetCount]){
                        for(PartnerFundAllocation pfa : Database.query(query)){
                        String accountUrl = Label.Core_MDF_PFRCommunityLink+pfa.ChannelPartnerId;
                        AllocationWrapper allocWrap = new AllocationWrapper();
                        allocWrap.accountName = pfa.ChannelPartner.name;
                        allocWrap.accountURL = accountUrl;
                        allocWrap.programName = pfa.Budget.Core_MDF_Program__r.name;
                        allocWrap.budgetType = pfa.Budget.Core_MDF_Budget_Type__c;
                        allocWrap.startDate = pfa.Budget.StartDate;
                        allocWrap.endDate = pfa.Budget.EndDate ;
                        allocWrap.amount = pfa.Amount;
                        allocWrap.totalActivityAllocAmount = pfa.Core_MDF_Total_Activity_Allocated_Amount__c;
                        allocWrap.unallocatedActAmount = pfa.Core_MDF_Available_Activity_Alloc_Amt__c;
                        allocWrap.totalApprovedFundClaims = pfa.TotalApprovedFcs;
                        allocWrap.unallocatedClaimAmount = pfa.Core_MDF_Available_Allocation_Amount__c ;
                        allocationWrapperList.add(allocWrap);
                    }
                }
                System.debug('End of Method - Allocations' +allocationWrapperList);
            }
            return allocationWrapperList;
        }
        //Creating a Wrapper class which would be used to display data from allocation,budget and account objects
        public class AllocationWrapper{
            @AuraEnabled public String accountName {get;set;} //Account Name
            @AuraEnabled public String accountURL {get;set;}   //Used to make account name as hyperlink
            @AuraEnabled public String programName {get;set;} //Budget Program
            @AuraEnabled public String budgetType {get;set;}  //Budget Type
            @AuraEnabled public Decimal amount {get;set;}     // Total Allocated Amount of PFA
            @AuraEnabled public Decimal totalActivityAllocAmount {get;set;} //Total Activity Allocation Amount of PFA
            @AuraEnabled public Decimal unallocatedActAmount {get;set;} // Unallocated Activity amount
            @AuraEnabled public Decimal totalApprovedFundClaims {get;set;} //Total Approved fund claim amount
            @AuraEnabled public Decimal unallocatedClaimAmount {get;set;} //Unallocated claim amount
            @AuraEnabled public Date startDate {get;set;} //Budget Start Date
            @AuraEnabled public Date endDate {get;set;} //Budget End Date
        
        } 
        @AuraEnabled(cacheable=true)
        public static List<AllocationWrapper> getTotalAllocations(String sortField,String direction){
            List<AllocationWrapper> allocationWrapperList = new List<AllocationWrapper>();
            Set<Id> accIds= new Set<Id>();
           // Integer limitCount = 3;
            //Get logged in user id 
            Id loggedInUser = UserInfo.getUserId(); 
            System.debug('User Id@@@' +loggedInUser);
            //Check if logged in user has custom permission
            Boolean hasPermission = FeatureManagement.checkPermission('Core_MDF_View_Custom_Allocation_Tab');
            if(hasPermission){
                //Get the Accounts associated with the logged in user through Account User records
                for(Core_MDF_Partner_Node_User_Mapping__c pnum :[Select id,Core_MDF_Account__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c =:loggedInUser]){
                    System.debug('Inside for loop of PNUM' +pnum.id);
                    if(pnum.Core_MDF_Account__c!=null){
                        accIds.add(pnum.Core_MDF_Account__c);
                    }
                }
                //Getting allocation records as per logged in user account access
                if(accIds.size()>0 && !accIds.isEmpty()){
                    for(PartnerFundAllocation pfa : [Select id,Title,Budget.StartDate, Budget.EndDate,Amount,ChannelPartner.name,ChannelPartnerId,Budget.Core_MDF_Program__r.name,toLabel(Budget.Core_MDF_Budget_Type__c),Core_MDF_Available_Allocation_Amount__c,Core_MDF_Total_Activity_Allocated_Amount__c, Core_MDF_Available_Activity_Alloc_Amt__c,TotalApprovedFcs  from PartnerFundAllocation where ChannelPartnerId IN: accIds
                                                    and Budget.Core_MDF_Budget_Type__c!=null]){
                        String accountUrl = Label.Core_MDF_PFRCommunityLink+pfa.ChannelPartnerId;
                        AllocationWrapper allocWrap = new AllocationWrapper();
                        allocWrap.accountName = pfa.ChannelPartner.name;
                        allocWrap.accountURL = accountUrl;
                        allocWrap.programName = pfa.Budget.Core_MDF_Program__r.name;
                        allocWrap.budgetType = pfa.Budget.Core_MDF_Budget_Type__c;
                        allocWrap.startDate = pfa.Budget.StartDate;
                        allocWrap.endDate = pfa.Budget.EndDate ;
                        allocWrap.amount = pfa.Amount;
                        allocWrap.totalActivityAllocAmount = pfa.Core_MDF_Total_Activity_Allocated_Amount__c;
                        allocWrap.unallocatedActAmount = pfa.Core_MDF_Available_Activity_Alloc_Amt__c;
                        allocWrap.totalApprovedFundClaims = pfa.TotalApprovedFcs;
                        allocWrap.unallocatedClaimAmount = pfa.Core_MDF_Available_Allocation_Amount__c ;
                        allocationWrapperList.add(allocWrap);
                    }
                }
                System.debug('End of Method - Allocations' +allocationWrapperList);
            }
            return allocationWrapperList;
        }
    }