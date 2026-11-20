@isTest
private class Core_IPS_HandleDeepLinksController_Test{



	@isTest static void testMethod1() {
		// code_block	
		Case CaseRecord = new Case(
            Status = 'New',
            Origin = 'Web',
            Priority = 'High',
            Subject = 'TestSubject',
            Description = 'TestDescription'
        );

		insert CaseRecord;
        
		Core_IPS_HandleDeepLinksController.getObjectNameById(CaseRecord.id);
	}

	@isTest static void testMethod2() {
		// code_block	
	}
}