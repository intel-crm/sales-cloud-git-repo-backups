global class BatchResultOrderTest implements Database.Batchable<Contact> {

    global Iterable<Contact> start(Database.BatchableContext bc) {

        return [SELECT Id, LastName FROM Contact LIMIT 10];
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {

        List<Contact> updateList = new List<Contact>();

        Integer counter = 0;

        for(Contact c : scope) {

            counter++;

            // Alternate success and failure
            if(Math.mod(counter, 2) == 0) {

                c.LastName = null; // causes error

            } else {

                c.LastName = c.LastName + '_Updated';
            }

            updateList.add(c);
        }

        Database.SaveResult[] results =
            Database.update(updateList, false);

        System.debug('===== RESULTS =====');

        for(Integer i=0; i<results.size(); i++) {

            if(results[i].isSuccess()) {

                System.debug('Index ' + i + ' => SUCCESS');

            } else {

                System.debug('Index ' + i + ' => ERROR');
            }
        }
    }

    global void finish(Database.BatchableContext bc) {

        System.debug('Batch Completed');
    }
}