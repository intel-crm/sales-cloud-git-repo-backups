/*Created By Areefa for testing*/
public  without sharing class Core_MDF_ClaimInsertForEinPred {
    public class CustomException extends Exception{}
    public static void claimProcessesForEinPredAfterInsert(Map<Id,PartnerFundClaim> newclaimMap){ //SendClaimIdToClaimPredictionObj 
        try{
            //String errorMess="";
           
            List<Core_MDF_Claim_Prediction_Event__e > plEventIdLst = new List<Core_MDF_Claim_Prediction_Event__e >();
            for(Id claimId :newclaimMap.keySet()){
                plEventIdLst.add(new Core_MDF_Claim_Prediction_Event__e(Core_MDF_PE_ID__c = claimId));            
            }
            List<Database.SaveResult> results = EventBus.publish(plEventIdLst); 
            integer cnt=0;
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()){
                    cnt+=1;
                    System.debug('count'+cnt);
                    if(cnt==3){Throw new CustomException('ERRORRRRRRR........');}
                    
                }else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage()); 
                        Throw new CustomException(err.getMessage());
                        //errorMess=err.getMessage();
                        //break;
                        //Throw new CustomException(''+err[0].getMessage());                        
                    	//err[0].getMessage() >0, capture err[0].getMessage() , throw
                    }                    
                }                
            }
            /*if(errorFlag){
                Throw new CustomException('Program cannot be empty');
            }*/
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }    
}
//Tested 
//Normal Claim : Creation which inturn inserted into claim prediction object :done
//Exception : created claim with exception on Ein Pred, o/p-> claim got created,due to exception claim dint inserted on claim prediction object :done
//Exception : Created claim with exception in 1 of the after insert method. o/p-> claim got created into claim & claim pred obj. claim obj claim struck in submitted bcz of exception.

//heap size[Limits.getHeapSize()] and CPU limit[Limits.getCpuTime()] : 12 diff(single record)/ try for bulk and see ,54
//	02:47:34.889 (5123637497)|USER_DEBUG|[46]|DEBUG|getHeapSize before claimProcessesForEinPredAfterInsert::::195260
//	02:47:34.889 (5123752530)|USER_DEBUG|[47]|DEBUG|getCpuTime before claimProcessesForEinPredAfterInsert::::698
//	02:47:34.889 (5176101880)|USER_DEBUG|[49]|DEBUG|getHeapSize After claimProcessesForEinPredAfterInsert::::195272
//	02:47:34.889 (5176256197)|USER_DEBUG|[50]|DEBUG|getCpuTime After claimProcessesForEinPredAfterInsert::::710

//Bulk Claim : working
//SOQL limit.[no change] - Use Plugin of soql analysier
//Query Even Obj: we cant query this