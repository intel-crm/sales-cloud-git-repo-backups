@IsTest
public class PSG_EmailMessageLogWrapperTest {
	
	static testMethod void testParse() {
		String json = '{\"attributes\":{\"type_z\":\"WorkflowAlert\",\"url\":\"/services/data/v41.0/tooling/sobjects/WorkflowAlert/01W2D0000008nVfUAI\"},\"Id\":\"01W2D0000008nVfUAI\",\"TemplateId\":\"00X2D000002h8LsUAI\",\"CcEmails\":null,\"Description\":\"Used to notify Tech team for DPA/ALN in submitted state for more than 30 minutes.\",\"DeveloperName\":\"PSG_DPA_ALN_Submitted_Notification\",\"SenderType\":\"OrgWideEmailAddress\",\"ManageableState\":\"unmanaged\",\"NamespacePrefix\":null,\"CreatedDate\":\"2022-07-13T07:54:49.000+0000\",\"CreatedById\":\"0052D000003WRXsQAO\",\"LastModifiedDate\":\"2022-08-16T05:59:23.000+0000\",\"LastModifiedById\":\"0052D000003WRXsQAO\",\"EntityDefinitionId\":\"01I2D000000NKZl\",\"Metadata\":{\"ccEmails\":[],\"description\":\"Used to notify Tech team for DPA/ALN in submitted state for more than 30 minutes.\",\"protected_z\":false,\"recipients\":[{\"field\":null,\"recipient\":\"11992929@intel.com.crm\",\"type_z\":\"user\"},{\"field\":null,\"recipient\":\"12073796@intel.com.crm\",\"type_z\":\"user\"}],\"senderAddress\":\"wsm-postmaster@intel.com\",\"senderType\":\"OrgWideEmailAddress\",\"template\":\"PSG_Email_Templates/PSG_DPA_ALN_Submitted_Notification\",\"urls\":null},\"FullName\":\"core_cpq_dpa_aln__c.PSG_DPA_ALN_Submitted_Notification\"}';
		PSG_EmailMessageLogWrapper obj = PSG_EmailMessageLogWrapper.parse(json);
		System.assert(obj != null);
	}
}