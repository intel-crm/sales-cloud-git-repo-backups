/***************************************************************************************************************************************
Apex Class Name     : PRM_VXRecommendation_Trigger 
Version             : 1.0
Created Date        : March 2020
Function            : Trigger for PRM_Value_Exchange_Recommendation__c.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Srishty                        17-March-2020                     US599996- This trigger will validate the Recommendation record  
                                                                   and will bypass validation for batch class 
*************************************************************************************************************************************/

trigger PRM_VXRecommendation_Trigger on PRM_Value_Exchange_Recommendation__c (before insert,after insert,before update,after update) {
  public static String CimPrimeEol=System.label.PRM_CIM_PRIME_Switch;// TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
    if(CimPrimeEol!='TRUE' || test.isrunningtest()){
    new PRM_VXRecommendation_Handler().run(); //TWC729-6800 EOL activities
    }
   
}