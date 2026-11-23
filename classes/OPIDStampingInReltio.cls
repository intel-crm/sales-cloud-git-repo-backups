//implements Queueable
public class OPIDStampingInReltio {
    /*List<Core_Account_Group_Member__c> cags;
    public OPIDStampingInReltio(List<Core_Account_Group_Member__c> cags) {
                            this.cags = cags;

              }
    public void execute(QueueableContext queCont) {*/ 
    @InvocableMethod(label='Send OPID to reltio' description='Returns the list of account names corresponding to the specified account IDs.' category='Account')
    public static void sendtoreltio(List<Core_Account_Group_Member__c>cags){
        List<UCD_ACM_ReltioModels.UpdateRequestModel> reltioList=new List<UCD_ACM_ReltioModels.UpdateRequestModel>();
        for(Core_Account_Group_Member__c cag:cags)
        {
            UCD_ACM_ReltioModels.UpdateRequestModel reltio=new UCD_ACM_ReltioModels.UpdateRequestModel();
            reltio.accountId=cag.Core_Intel_Account_Id__c;
            reltio.onePartnerId=cag.Core_Partner_Account_Id__c;
            reltio.oPIdStatus=cag.Core_Inactive_Ind__c;
            reltioList.add(reltio);
        }
        System.debug(reltioList);
        UCD_ACM_ReltioController.sendOPIDUpdateToReltio(reltioList);
               }

}