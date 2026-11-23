trigger Core_TopicAssignmentTrigger on TopicAssignment (before insert,before update,after update, after insert,after Delete) {
    // new Core_TopicAssignmentHandler().run(); //IPA2.0:TWC729-8114 Topics Removal/Event Removal
}