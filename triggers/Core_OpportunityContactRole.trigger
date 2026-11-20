trigger Core_OpportunityContactRole on OpportunityContactRole (before insert, before update) {
		new Core_OpportunityContactRoleHelper().run();
}